#include "ConverterController.h"

#include "converters/EncodingConverter.h"
#include "converters/ImageConverter.h"
#include "converters/DataConverter.h"
#include "converters/EncodeConverter.h"
#include "converters/VideoConverter.h"

#include <QFileInfo>
#include <QDir>
#include <QLocale>

namespace {

// If the user typed an output path without (or with the wrong) extension,
// glue the correct one on so Windows recognises the resulting file. We
// only append — never silently rewrite an existing extension that is also
// valid for the target (e.g. .jpeg for JPG). This is how almost every
// "save as" dialog in the wild behaves.
QString ensureExtension(const QString &path, const QStringList &validExts)
{
    if (path.isEmpty() || validExts.isEmpty()) return path;
    const QFileInfo info(path);
    const QString suffix = info.suffix().toLower();
    for (const QString &candidate : validExts) {
        QString c = candidate.toLower();
        if (c.startsWith('.')) c.remove(0, 1);
        if (suffix == c) return path; // already a valid extension
    }
    QString primary = validExts.first().toLower();
    if (!primary.startsWith('.')) primary.prepend('.');
    return path + primary;
}

QStringList imageExtsFor(const QString &targetFormat)
{
    const QString f = targetFormat.toUpper();
    if (f == "JPG" || f == "JPEG") return { ".jpg", ".jpeg" };
    if (f == "TIFF" || f == "TIF") return { ".tiff", ".tif" };
    return { '.' + targetFormat.toLower() };
}

QStringList dataExtsFor(const QString &mode)
{
    if (mode.contains("JSON", Qt::CaseInsensitive) && mode.contains("CSV", Qt::CaseInsensitive)) {
        // direction matters
        if (mode.startsWith("CSV", Qt::CaseInsensitive)) return { ".json" };
        return { ".csv" };
    }
    if (mode.contains("HTML", Qt::CaseInsensitive)) return { ".html", ".htm" };
    return { ".txt" };
}

QStringList encodeExtsFor(const QString &mode)
{
    const bool isDecode = mode.contains("decode", Qt::CaseInsensitive);
    if (isDecode) return { ".bin" };
    if (mode.startsWith("Hex", Qt::CaseInsensitive)) return { ".hex", ".txt" };
    return { ".b64", ".txt" }; // Base64 encode
}

QStringList videoExtsFor(const QString &mode)
{
    if (mode.contains("MP4")) return { ".mp4", ".mov", ".m4v" };
    if (mode.contains("GIF")) return { ".gif" };
    if (mode.contains("PNG") || mode.contains("Изображение")) return { ".png", ".jpg", ".jpeg" };
    return { ".bin" };
}

} // namespace

ConverterController::ConverterController(QObject *parent)
    : QObject(parent)
{
}

QStringList ConverterController::encodingFormats() const
{
    return EncodingConverter::supportedEncodings();
}

QStringList ConverterController::imageFormats() const
{
    return ImageConverter::supportedFormats();
}

QStringList ConverterController::dataFormats() const
{
    return DataConverter::supportedModes();
}

QStringList ConverterController::encodeFormats() const
{
    return EncodeConverter::supportedModes();
}

QStringList ConverterController::videoModes() const
{
    return VideoConverter::supportedModes();
}

bool ConverterController::ffmpegAvailable() const
{
    return !VideoConverter::locateFfmpeg().isEmpty();
}

QString ConverterController::toLocalPath(const QUrl &url) const
{
    if (url.isLocalFile()) {
        return url.toLocalFile();
    }
    return url.toString();
}

QString ConverterController::suggestOutputPath(const QString &inputPath, const QString &targetExt) const
{
    if (inputPath.isEmpty()) {
        return QString();
    }
    QFileInfo info(inputPath);
    QString ext = targetExt;
    if (!ext.startsWith('.')) {
        ext.prepend('.');
    }
    QString base = info.completeBaseName();
    QString candidate = info.absolutePath() + QDir::separator() + base + "_converted" + ext;
    int counter = 1;
    while (QFileInfo::exists(candidate)) {
        candidate = info.absolutePath() + QDir::separator() + base
                    + QStringLiteral("_converted_%1").arg(counter) + ext;
        ++counter;
    }
    return candidate;
}

QString ConverterController::fileSizeHuman(const QString &path) const
{
    QFileInfo info(path);
    if (!info.exists()) {
        return QStringLiteral("—");
    }
    return QLocale().formattedDataSize(info.size(), 2, QLocale::DataSizeIecFormat);
}

QString ConverterController::detectEncoding(const QString &inputPath) const
{
    return EncodingConverter::detectEncoding(inputPath);
}

void ConverterController::setBusy(bool busy)
{
    if (m_busy != busy) {
        m_busy = busy;
        emit busyChanged();
    }
}

void ConverterController::emitFinished(bool success, const QString &outputPath, const QString &message)
{
    m_lastMessage = message;
    emit lastMessageChanged();
    setBusy(false);
    emit conversionFinished(success, outputPath, message);
}

bool ConverterController::convertEncoding(const QString &inputPath,
                                          const QString &outputPath,
                                          const QString &fromEncoding,
                                          const QString &toEncoding)
{
    setBusy(true);
    const QString fixedOut = ensureExtension(outputPath, { ".txt" });
    QString err;
    const bool ok = EncodingConverter::convert(inputPath, fixedOut, fromEncoding, toEncoding, &err);
    if (ok) {
        emitFinished(true, fixedOut, QStringLiteral("Готово: %1 → %2").arg(fromEncoding, toEncoding));
    } else {
        emitFinished(false, fixedOut, err.isEmpty() ? QStringLiteral("Ошибка") : err);
    }
    return ok;
}

bool ConverterController::convertImage(const QString &inputPath,
                                       const QString &outputPath,
                                       const QString &targetFormat,
                                       int quality)
{
    setBusy(true);
    const QString fixedOut = ensureExtension(outputPath, imageExtsFor(targetFormat));
    QString err;
    const bool ok = ImageConverter::convert(inputPath, fixedOut, targetFormat, quality, &err);
    if (ok) {
        emitFinished(true, fixedOut, QStringLiteral("Готово: → %1 (q=%2)").arg(targetFormat).arg(quality));
    } else {
        emitFinished(false, fixedOut, err.isEmpty() ? QStringLiteral("Ошибка") : err);
    }
    return ok;
}

bool ConverterController::convertData(const QString &inputPath,
                                      const QString &outputPath,
                                      const QString &mode)
{
    setBusy(true);
    const QString fixedOut = ensureExtension(outputPath, dataExtsFor(mode));
    QString err;
    const bool ok = DataConverter::convert(inputPath, fixedOut, mode, &err);
    if (ok) {
        emitFinished(true, fixedOut, QStringLiteral("Готово: %1").arg(mode));
    } else {
        emitFinished(false, fixedOut, err.isEmpty() ? QStringLiteral("Ошибка") : err);
    }
    return ok;
}

bool ConverterController::convertEncode(const QString &inputPath,
                                        const QString &outputPath,
                                        const QString &mode)
{
    setBusy(true);
    const QString fixedOut = ensureExtension(outputPath, encodeExtsFor(mode));
    QString err;
    const bool ok = EncodeConverter::convert(inputPath, fixedOut, mode, &err);
    if (ok) {
        emitFinished(true, fixedOut, QStringLiteral("Готово: %1").arg(mode));
    } else {
        emitFinished(false, fixedOut, err.isEmpty() ? QStringLiteral("Ошибка") : err);
    }
    return ok;
}

bool ConverterController::convertVideo(const QString &inputPath,
                                       const QString &outputPath,
                                       const QString &mode,
                                       int durationSec,
                                       int fps,
                                       int maxWidth)
{
    setBusy(true);
    const QString fixedOut = ensureExtension(outputPath, videoExtsFor(mode));
    QString err;
    const bool ok = VideoConverter::convert(inputPath, fixedOut, mode,
                                            durationSec, fps, maxWidth, &err);
    if (ok) {
        emitFinished(true, fixedOut, QStringLiteral("Готово: %1").arg(mode));
    } else {
        emitFinished(false, fixedOut, err.isEmpty() ? QStringLiteral("Ошибка") : err);
    }
    return ok;
}

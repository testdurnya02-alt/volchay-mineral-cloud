#include "ImageConverter.h"

#include <QImage>
#include <QImageReader>
#include <QImageWriter>
#include <QFileInfo>
#include <QSet>

QStringList ImageConverter::supportedFormats()
{
    static const QStringList preferred = {
        QStringLiteral("PNG"),
        QStringLiteral("JPG"),
        QStringLiteral("BMP"),
        QStringLiteral("WEBP"),
        QStringLiteral("TIFF"),
        QStringLiteral("ICO"),
        QStringLiteral("PPM"),
        QStringLiteral("XBM"),
    };
    QSet<QString> available;
    for (const QByteArray &fmt : QImageWriter::supportedImageFormats()) {
        available.insert(QString::fromLatin1(fmt).toUpper());
    }
    QStringList out;
    for (const QString &p : preferred) {
        QString key = p == QStringLiteral("JPG") ? QStringLiteral("JPEG") : p;
        if (available.contains(key) || available.contains(p)) {
            out << p;
        }
    }
    return out;
}

bool ImageConverter::convert(const QString &inputPath,
                             const QString &outputPath,
                             const QString &targetFormat,
                             int quality,
                             QString *errorOut)
{
    QImageReader reader(inputPath);
    reader.setAutoTransform(true);
    QImage image = reader.read();
    if (image.isNull()) {
        if (errorOut) *errorOut = QStringLiteral("Не удалось прочитать изображение: %1")
                                      .arg(reader.errorString());
        return false;
    }

    const QString fmt = targetFormat.toUpper();
    QByteArray writerFmt = fmt.toLatin1();
    if (fmt == "JPG") {
        writerFmt = "jpeg";
    }

    QImageWriter writer(outputPath, writerFmt);
    if (quality > 0 && quality <= 100) {
        writer.setQuality(quality);
    }
    if (!writer.write(image)) {
        if (errorOut) *errorOut = QStringLiteral("Не удалось записать изображение: %1")
                                      .arg(writer.errorString());
        return false;
    }
    return true;
}

#include "VideoConverter.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>
#include <QTemporaryDir>

namespace {

bool runFfmpeg(const QString &ffmpeg,
               const QStringList &args,
               QString *errorOut)
{
    QProcess proc;
    proc.setProcessChannelMode(QProcess::MergedChannels);
    proc.start(ffmpeg, args);
    if (!proc.waitForStarted(8000)) {
        if (errorOut) *errorOut = QStringLiteral("ffmpeg не запустился: %1").arg(proc.errorString());
        return false;
    }
    // Hard cap: 5 minutes per conversion. Long videos are expected to be
    // short clips; this is a safety net against pathological inputs.
    if (!proc.waitForFinished(5 * 60 * 1000)) {
        proc.kill();
        if (errorOut) *errorOut = QStringLiteral("ffmpeg превысил лимит времени");
        return false;
    }
    const QString out = QString::fromLocal8Bit(proc.readAll());
    if (proc.exitStatus() != QProcess::NormalExit || proc.exitCode() != 0) {
        if (errorOut) {
            // Take the last meaningful line of ffmpeg output for the toast.
            QString tail = out.trimmed();
            const int nl = tail.lastIndexOf('\n');
            if (nl > 0) tail = tail.mid(nl + 1).trimmed();
            *errorOut = QStringLiteral("ffmpeg: %1").arg(tail.isEmpty() ? proc.errorString() : tail);
        }
        return false;
    }
    return true;
}

QString scaleFilter(int maxWidth)
{
    // Scale only if requested AND down-only — never upscale by accident.
    // -2 keeps aspect ratio and forces an even number for h264.
    if (maxWidth <= 0) return QStringLiteral("scale=trunc(iw/2)*2:trunc(ih/2)*2");
    return QStringLiteral("scale='min(%1,iw)':-2:flags=lanczos").arg(maxWidth);
}

} // namespace

QStringList VideoConverter::supportedModes()
{
    return {
        QStringLiteral("Изображение → Видео (MP4)"),
        QStringLiteral("Видео → Изображение (PNG)"),
        QStringLiteral("Изображение → GIF"),
        QStringLiteral("GIF → Изображение (PNG)"),
        QStringLiteral("Видео → GIF"),
        QStringLiteral("GIF → Видео (MP4)"),
    };
}

QString VideoConverter::locateFfmpeg()
{
    // 1) explicit override
    const QByteArray envOverride = qgetenv("VOLCHAY_FFMPEG");
    if (!envOverride.isEmpty()) {
        const QString p = QString::fromLocal8Bit(envOverride);
        if (QFileInfo::exists(p)) return p;
    }

    // 2) bundled binary next to the executable
    const QString appDir = QCoreApplication::applicationDirPath();
    const QStringList candidates = {
#ifdef Q_OS_WIN
        appDir + QStringLiteral("/ffmpeg.exe"),
        appDir + QStringLiteral("/bin/ffmpeg.exe"),
#else
        appDir + QStringLiteral("/ffmpeg"),
        appDir + QStringLiteral("/bin/ffmpeg"),
#endif
    };
    for (const QString &c : candidates) {
        if (QFileInfo::exists(c)) return c;
    }

    // 3) PATH
    const QString found = QStandardPaths::findExecutable(QStringLiteral("ffmpeg"));
    return found;
}

bool VideoConverter::convert(const QString &inputPath,
                             const QString &outputPath,
                             const QString &mode,
                             int durationSec,
                             int fps,
                             int maxWidth,
                             QString *errorOut)
{
    if (inputPath.isEmpty() || outputPath.isEmpty()) {
        if (errorOut) *errorOut = QStringLiteral("Не задан путь");
        return false;
    }
    if (!QFileInfo::exists(inputPath)) {
        if (errorOut) *errorOut = QStringLiteral("Источник не найден");
        return false;
    }

    const QString ffmpeg = locateFfmpeg();
    if (ffmpeg.isEmpty()) {
        if (errorOut) *errorOut = QStringLiteral("ffmpeg не найден. Положи ffmpeg.exe рядом с программой или установи в PATH.");
        return false;
    }

    durationSec = qBound(1, durationSec, 60);
    fps         = qBound(1, fps, 30);
    const QString filter = scaleFilter(maxWidth);

    QStringList args;
    args << "-y" << "-hide_banner" << "-loglevel" << "error";

    if (mode == "Изображение → Видео (MP4)") {
        // Loop a single image for N seconds, encode to H.264 + yuv420p.
        args << "-loop" << "1"
             << "-i" << inputPath
             << "-t" << QString::number(durationSec)
             << "-vf" << filter
             << "-c:v" << "libx264"
             << "-pix_fmt" << "yuv420p"
             << "-r" << "25"
             << "-movflags" << "+faststart"
             << outputPath;
    } else if (mode == "Видео → Изображение (PNG)") {
        // Grab the first frame.
        args << "-i" << inputPath
             << "-frames:v" << "1"
             << "-vf" << filter
             << outputPath;
    } else if (mode == "Изображение → GIF") {
        args << "-i" << inputPath
             << "-vf" << filter
             << "-loop" << "0"
             << outputPath;
    } else if (mode == "GIF → Изображение (PNG)") {
        args << "-i" << inputPath
             << "-frames:v" << "1"
             << "-vf" << filter
             << outputPath;
    } else if (mode == "Видео → GIF") {
        // Two-pass with a generated palette for high quality. Use a temp
        // dir so we don't pollute the output folder.
        QTemporaryDir tmp;
        if (!tmp.isValid()) {
            if (errorOut) *errorOut = QStringLiteral("Не создать временную папку");
            return false;
        }
        const QString palette = tmp.filePath("palette.png");

        const QString gifFilter = QStringLiteral("fps=%1,%2").arg(fps).arg(filter);
        QStringList passOne {
            "-y", "-hide_banner", "-loglevel", "error",
            "-i", inputPath,
            "-vf", gifFilter + ",palettegen",
            palette,
        };
        if (!runFfmpeg(ffmpeg, passOne, errorOut)) return false;

        QStringList passTwo {
            "-y", "-hide_banner", "-loglevel", "error",
            "-i", inputPath,
            "-i", palette,
            "-lavfi", gifFilter + " [x]; [x][1:v] paletteuse",
            outputPath,
        };
        return runFfmpeg(ffmpeg, passTwo, errorOut);
    } else if (mode == "GIF → Видео (MP4)") {
        args << "-i" << inputPath
             << "-vf" << filter
             << "-c:v" << "libx264"
             << "-pix_fmt" << "yuv420p"
             << "-movflags" << "+faststart"
             << outputPath;
    } else {
        if (errorOut) *errorOut = QStringLiteral("Неизвестный режим: %1").arg(mode);
        return false;
    }

    return runFfmpeg(ffmpeg, args, errorOut);
}

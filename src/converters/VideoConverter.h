#pragma once

#include <QString>
#include <QStringList>

// VideoConverter wraps an `ffmpeg` subprocess to provide image/video/gif
// inter-conversion. The ffmpeg binary is located at runtime via:
//   1. environment variable VOLCHAY_FFMPEG (override for tests)
//   2. an ffmpeg binary placed next to the application executable
//   3. PATH lookup ("ffmpeg")
class VideoConverter
{
public:
    // Mode strings exposed to QML.
    static QStringList supportedModes();

    // Best-effort discovery; empty string means we couldn't find ffmpeg.
    static QString locateFfmpeg();

    // Synchronous conversion. Long operations should be wrapped on the QML
    // side by showing the busy indicator the controller already exposes.
    //
    //   inputPath   — source file
    //   outputPath  — destination file (caller is responsible for the .ext)
    //   mode        — one of the strings returned by supportedModes()
    //   durationSec — only used by "Image → Video" / "Image → GIF" (1..30)
    //   fps         — used by "Video → GIF" / "GIF → Video" (default 15)
    //   maxWidth    — optional resize (0 = keep original)
    static bool convert(const QString &inputPath,
                        const QString &outputPath,
                        const QString &mode,
                        int durationSec = 4,
                        int fps = 15,
                        int maxWidth = 0,
                        QString *errorOut = nullptr);
};

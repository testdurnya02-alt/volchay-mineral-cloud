#pragma once

#include <QString>
#include <QStringList>

class ImageConverter
{
public:
    static QStringList supportedFormats();
    static bool convert(const QString &inputPath,
                        const QString &outputPath,
                        const QString &targetFormat,
                        int quality,
                        QString *errorOut = nullptr);
};

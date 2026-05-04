#pragma once

#include <QString>
#include <QStringList>

class EncodeConverter
{
public:
    static QStringList supportedModes();
    static bool convert(const QString &inputPath,
                        const QString &outputPath,
                        const QString &mode,
                        QString *errorOut = nullptr);
};

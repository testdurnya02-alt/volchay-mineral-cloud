#pragma once

#include <QString>
#include <QStringList>

class EncodingConverter
{
public:
    static QStringList supportedEncodings();
    static QString detectEncoding(const QString &inputPath);
    static bool convert(const QString &inputPath,
                        const QString &outputPath,
                        const QString &fromEncoding,
                        const QString &toEncoding,
                        QString *errorOut = nullptr);
};

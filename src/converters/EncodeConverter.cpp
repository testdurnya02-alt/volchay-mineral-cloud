#include "EncodeConverter.h"

#include <QFile>
#include <QByteArray>

namespace {

bool encodeBase64(const QString &in, const QString &out, QString *err)
{
    QFile fi(in);
    if (!fi.open(QIODevice::ReadOnly)) { if (err) *err = QStringLiteral("Не открыть вход"); return false; }
    QByteArray data = fi.readAll();
    fi.close();
    QFile fo(out);
    if (!fo.open(QIODevice::WriteOnly | QIODevice::Truncate)) { if (err) *err = QStringLiteral("Не открыть выход"); return false; }
    fo.write(data.toBase64());
    fo.close();
    return true;
}

bool decodeBase64(const QString &in, const QString &out, QString *err)
{
    QFile fi(in);
    if (!fi.open(QIODevice::ReadOnly)) { if (err) *err = QStringLiteral("Не открыть вход"); return false; }
    QByteArray data = fi.readAll();
    fi.close();
    QByteArray decoded = QByteArray::fromBase64(data, QByteArray::AbortOnBase64DecodingErrors);
    if (decoded.isEmpty() && !data.trimmed().isEmpty()) {
        if (err) *err = QStringLiteral("Невалидный Base64");
        return false;
    }
    QFile fo(out);
    if (!fo.open(QIODevice::WriteOnly | QIODevice::Truncate)) { if (err) *err = QStringLiteral("Не открыть выход"); return false; }
    fo.write(decoded);
    fo.close();
    return true;
}

bool encodeHex(const QString &in, const QString &out, QString *err)
{
    QFile fi(in);
    if (!fi.open(QIODevice::ReadOnly)) { if (err) *err = QStringLiteral("Не открыть вход"); return false; }
    QByteArray data = fi.readAll();
    fi.close();
    QFile fo(out);
    if (!fo.open(QIODevice::WriteOnly | QIODevice::Truncate)) { if (err) *err = QStringLiteral("Не открыть выход"); return false; }
    fo.write(data.toHex(' '));
    fo.close();
    return true;
}

bool decodeHex(const QString &in, const QString &out, QString *err)
{
    QFile fi(in);
    if (!fi.open(QIODevice::ReadOnly)) { if (err) *err = QStringLiteral("Не открыть вход"); return false; }
    QByteArray data = fi.readAll();
    fi.close();
    data.replace(' ', "").replace('\n', "").replace('\r', "").replace('\t', "");
    QByteArray decoded = QByteArray::fromHex(data);
    QFile fo(out);
    if (!fo.open(QIODevice::WriteOnly | QIODevice::Truncate)) { if (err) *err = QStringLiteral("Не открыть выход"); return false; }
    fo.write(decoded);
    fo.close();
    return true;
}

} // anonymous namespace

QStringList EncodeConverter::supportedModes()
{
    return {
        QStringLiteral("Base64: encode"),
        QStringLiteral("Base64: decode"),
        QStringLiteral("Hex: encode"),
        QStringLiteral("Hex: decode"),
    };
}

bool EncodeConverter::convert(const QString &inputPath,
                              const QString &outputPath,
                              const QString &mode,
                              QString *errorOut)
{
    if (mode == QStringLiteral("Base64: encode")) return encodeBase64(inputPath, outputPath, errorOut);
    if (mode == QStringLiteral("Base64: decode")) return decodeBase64(inputPath, outputPath, errorOut);
    if (mode == QStringLiteral("Hex: encode"))    return encodeHex(inputPath, outputPath, errorOut);
    if (mode == QStringLiteral("Hex: decode"))    return decodeHex(inputPath, outputPath, errorOut);
    if (errorOut) *errorOut = QStringLiteral("Неизвестный режим: %1").arg(mode);
    return false;
}

#include "EncodingConverter.h"

#include <QFile>
#include <QFileInfo>
#include <QStringConverter>
#include <QStringDecoder>
#include <QStringEncoder>
#include <QtCore5Compat/QTextCodec>

namespace {

struct EncodingEntry {
    const char *displayName;
    const char *codecName;
};

const QList<EncodingEntry> &table()
{
    static const QList<EncodingEntry> data = {
        { "UTF-8",        "UTF-8" },
        { "UTF-8 + BOM",  "UTF-8-BOM" },
        { "UTF-16 LE",    "UTF-16LE" },
        { "UTF-16 BE",    "UTF-16BE" },
        { "UTF-32 LE",    "UTF-32LE" },
        { "UTF-32 BE",    "UTF-32BE" },
        { "Windows-1251", "windows-1251" },
        { "Windows-1252", "windows-1252" },
        { "KOI8-R",       "KOI8-R" },
        { "KOI8-U",       "KOI8-U" },
        { "ISO-8859-1",   "ISO-8859-1" },
        { "ISO-8859-5",   "ISO-8859-5" },
        { "CP866",        "IBM866" },
        { "Mac Cyrillic", "macintosh" },
    };
    return data;
}

QByteArray codecFor(const QString &displayName)
{
    for (const auto &e : table()) {
        if (QString::fromLatin1(e.displayName) == displayName) {
            return QByteArray(e.codecName);
        }
    }
    return QByteArray();
}

QString decodeBytes(const QByteArray &bytes, const QString &encoding, QString *err)
{
    QByteArray codec = codecFor(encoding);
    if (codec.isEmpty()) {
        if (err) *err = QStringLiteral("Неизвестная исходная кодировка: %1").arg(encoding);
        return QString();
    }
    if (codec == "UTF-8-BOM") {
        QByteArray clean = bytes;
        if (clean.startsWith("\xEF\xBB\xBF")) {
            clean.remove(0, 3);
        }
        QStringDecoder dec(QStringConverter::Utf8);
        QString out = dec.decode(clean);
        if (dec.hasError() && err) *err = QStringLiteral("Не удалось декодировать как UTF-8");
        return out;
    }
    if (codec == "UTF-8" || codec == "UTF-16LE" || codec == "UTF-16BE"
        || codec == "UTF-32LE" || codec == "UTF-32BE") {
        QStringConverter::Encoding e = QStringConverter::Utf8;
        if (codec == "UTF-16LE") e = QStringConverter::Utf16LE;
        else if (codec == "UTF-16BE") e = QStringConverter::Utf16BE;
        else if (codec == "UTF-32LE") e = QStringConverter::Utf32LE;
        else if (codec == "UTF-32BE") e = QStringConverter::Utf32BE;
        QStringDecoder dec(e);
        QString out = dec.decode(bytes);
        if (dec.hasError() && err) *err = QStringLiteral("Не удалось декодировать как %1").arg(encoding);
        return out;
    }
    QTextCodec *tc = QTextCodec::codecForName(codec);
    if (!tc) {
        if (err) *err = QStringLiteral("Кодек недоступен: %1").arg(QString::fromLatin1(codec));
        return QString();
    }
    return tc->toUnicode(bytes);
}

QByteArray encodeString(const QString &text, const QString &encoding, QString *err)
{
    QByteArray codec = codecFor(encoding);
    if (codec.isEmpty()) {
        if (err) *err = QStringLiteral("Неизвестная целевая кодировка: %1").arg(encoding);
        return QByteArray();
    }
    if (codec == "UTF-8-BOM") {
        QStringEncoder enc(QStringConverter::Utf8);
        QByteArray out;
        out.append("\xEF\xBB\xBF", 3);
        out.append(enc.encode(text));
        return out;
    }
    if (codec == "UTF-8" || codec == "UTF-16LE" || codec == "UTF-16BE"
        || codec == "UTF-32LE" || codec == "UTF-32BE") {
        QStringConverter::Encoding e = QStringConverter::Utf8;
        if (codec == "UTF-16LE") e = QStringConverter::Utf16LE;
        else if (codec == "UTF-16BE") e = QStringConverter::Utf16BE;
        else if (codec == "UTF-32LE") e = QStringConverter::Utf32LE;
        else if (codec == "UTF-32BE") e = QStringConverter::Utf32BE;
        QStringEncoder enc(e);
        return enc.encode(text);
    }
    QTextCodec *tc = QTextCodec::codecForName(codec);
    if (!tc) {
        if (err) *err = QStringLiteral("Кодек недоступен: %1").arg(QString::fromLatin1(codec));
        return QByteArray();
    }
    return tc->fromUnicode(text);
}

} // anonymous namespace

QStringList EncodingConverter::supportedEncodings()
{
    QStringList out;
    out.reserve(table().size());
    for (const auto &e : table()) {
        out << QString::fromLatin1(e.displayName);
    }
    return out;
}

QString EncodingConverter::detectEncoding(const QString &inputPath)
{
    QFile file(inputPath);
    if (!file.open(QIODevice::ReadOnly)) {
        return QString();
    }
    QByteArray head = file.read(4);
    if (head.startsWith("\xEF\xBB\xBF")) return QStringLiteral("UTF-8 + BOM");
    if (head.startsWith("\xFF\xFE\x00\x00")) return QStringLiteral("UTF-32 LE");
    if (head.startsWith("\x00\x00\xFE\xFF")) return QStringLiteral("UTF-32 BE");
    if (head.startsWith("\xFF\xFE")) return QStringLiteral("UTF-16 LE");
    if (head.startsWith("\xFE\xFF")) return QStringLiteral("UTF-16 BE");
    return QStringLiteral("UTF-8");
}

bool EncodingConverter::convert(const QString &inputPath,
                                const QString &outputPath,
                                const QString &fromEncoding,
                                const QString &toEncoding,
                                QString *errorOut)
{
    QFile in(inputPath);
    if (!in.open(QIODevice::ReadOnly)) {
        if (errorOut) *errorOut = QStringLiteral("Не удалось открыть входной файл");
        return false;
    }
    QByteArray bytes = in.readAll();
    in.close();

    QString text = decodeBytes(bytes, fromEncoding, errorOut);
    if (errorOut && !errorOut->isEmpty()) return false;

    QByteArray encoded = encodeString(text, toEncoding, errorOut);
    if (errorOut && !errorOut->isEmpty()) return false;

    QFile out(outputPath);
    if (!out.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        if (errorOut) *errorOut = QStringLiteral("Не удалось открыть выходной файл");
        return false;
    }
    qint64 written = out.write(encoded);
    out.close();
    if (written != encoded.size()) {
        if (errorOut) *errorOut = QStringLiteral("Запись не завершилась полностью");
        return false;
    }
    return true;
}

#include "DataConverter.h"

#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QStringList>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QRegularExpression>
#include <QStringConverter>

namespace {

QStringList parseCsvLine(const QString &line, QChar delim = ',')
{
    QStringList fields;
    QString current;
    bool inQuotes = false;
    for (int i = 0; i < line.size(); ++i) {
        const QChar c = line.at(i);
        if (inQuotes) {
            if (c == '"') {
                if (i + 1 < line.size() && line.at(i + 1) == '"') {
                    current.append('"');
                    ++i;
                } else {
                    inQuotes = false;
                }
            } else {
                current.append(c);
            }
        } else {
            if (c == '"') {
                inQuotes = true;
            } else if (c == delim) {
                fields << current;
                current.clear();
            } else {
                current.append(c);
            }
        }
    }
    fields << current;
    return fields;
}

QString escapeCsvField(const QString &field, QChar delim = ',')
{
    bool needsQuotes = field.contains(delim) || field.contains('"')
                       || field.contains('\n') || field.contains('\r');
    if (!needsQuotes) {
        return field;
    }
    QString escaped = field;
    escaped.replace('"', QStringLiteral("\"\""));
    return '"' + escaped + '"';
}

QStringList splitLines(const QString &text)
{
    QStringList out;
    int start = 0;
    bool inQuotes = false;
    for (int i = 0; i < text.size(); ++i) {
        const QChar c = text.at(i);
        if (c == '"') {
            inQuotes = !inQuotes;
        } else if (!inQuotes && (c == '\n' || c == '\r')) {
            out << text.mid(start, i - start);
            if (c == '\r' && i + 1 < text.size() && text.at(i + 1) == '\n') {
                ++i;
            }
            start = i + 1;
        }
    }
    if (start < text.size()) {
        out << text.mid(start);
    }
    return out;
}

bool csvToJson(const QString &inputPath, const QString &outputPath, QString *errorOut)
{
    QFile in(inputPath);
    if (!in.open(QIODevice::ReadOnly)) {
        if (errorOut) *errorOut = QStringLiteral("Не удалось открыть входной CSV");
        return false;
    }
    QTextStream stream(&in);
    stream.setEncoding(QStringConverter::Utf8);
    const QString all = stream.readAll();
    in.close();

    const QStringList lines = splitLines(all);
    if (lines.isEmpty()) {
        if (errorOut) *errorOut = QStringLiteral("Пустой CSV");
        return false;
    }
    const QStringList headers = parseCsvLine(lines.first());

    QJsonArray array;
    for (int i = 1; i < lines.size(); ++i) {
        const QString &line = lines.at(i);
        if (line.trimmed().isEmpty()) continue;
        const QStringList fields = parseCsvLine(line);
        QJsonObject obj;
        for (int c = 0; c < headers.size(); ++c) {
            const QString key = headers.at(c);
            const QString val = c < fields.size() ? fields.at(c) : QString();
            bool ok = false;
            const double num = val.toDouble(&ok);
            if (ok && !val.isEmpty() && val.trimmed() == val) {
                obj.insert(key, num);
            } else if (val == QStringLiteral("true")) {
                obj.insert(key, true);
            } else if (val == QStringLiteral("false")) {
                obj.insert(key, false);
            } else if (val.isEmpty()) {
                obj.insert(key, QJsonValue::Null);
            } else {
                obj.insert(key, val);
            }
        }
        array.append(obj);
    }

    QJsonDocument doc(array);
    QFile out(outputPath);
    if (!out.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        if (errorOut) *errorOut = QStringLiteral("Не удалось открыть выходной JSON");
        return false;
    }
    out.write(doc.toJson(QJsonDocument::Indented));
    out.close();
    return true;
}

bool jsonToCsv(const QString &inputPath, const QString &outputPath, QString *errorOut)
{
    QFile in(inputPath);
    if (!in.open(QIODevice::ReadOnly)) {
        if (errorOut) *errorOut = QStringLiteral("Не удалось открыть входной JSON");
        return false;
    }
    QByteArray data = in.readAll();
    in.close();

    QJsonParseError perr;
    QJsonDocument doc = QJsonDocument::fromJson(data, &perr);
    if (perr.error != QJsonParseError::NoError) {
        if (errorOut) *errorOut = QStringLiteral("Невалидный JSON: %1").arg(perr.errorString());
        return false;
    }
    if (!doc.isArray()) {
        if (errorOut) *errorOut = QStringLiteral("Ожидался JSON-массив объектов");
        return false;
    }
    const QJsonArray array = doc.array();
    QStringList headers;
    for (const QJsonValue &v : array) {
        if (!v.isObject()) continue;
        const QJsonObject obj = v.toObject();
        for (auto it = obj.constBegin(); it != obj.constEnd(); ++it) {
            if (!headers.contains(it.key())) {
                headers << it.key();
            }
        }
    }
    if (headers.isEmpty()) {
        if (errorOut) *errorOut = QStringLiteral("Не удалось извлечь заголовки");
        return false;
    }

    QFile out(outputPath);
    if (!out.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        if (errorOut) *errorOut = QStringLiteral("Не удалось открыть выходной CSV");
        return false;
    }
    QTextStream stream(&out);
    stream.setEncoding(QStringConverter::Utf8);
    QStringList headerEscaped;
    for (const QString &h : headers) headerEscaped << escapeCsvField(h);
    stream << headerEscaped.join(',') << "\r\n";

    for (const QJsonValue &v : array) {
        const QJsonObject obj = v.toObject();
        QStringList row;
        for (const QString &h : headers) {
            const QJsonValue val = obj.value(h);
            QString cell;
            if (val.isString()) cell = val.toString();
            else if (val.isDouble()) cell = QString::number(val.toDouble(), 'g', 15);
            else if (val.isBool()) cell = val.toBool() ? QStringLiteral("true") : QStringLiteral("false");
            else if (val.isNull()) cell = QString();
            else if (val.isArray() || val.isObject()) cell = QString::fromUtf8(QJsonDocument(
                val.isArray() ? QJsonDocument(val.toArray()) : QJsonDocument(val.toObject())).toJson(QJsonDocument::Compact));
            row << escapeCsvField(cell);
        }
        stream << row.join(',') << "\r\n";
    }
    out.close();
    return true;
}

QString escapeHtml(const QString &s)
{
    QString r;
    r.reserve(s.size());
    for (const QChar c : s) {
        switch (c.unicode()) {
        case '&': r += QStringLiteral("&amp;"); break;
        case '<': r += QStringLiteral("&lt;"); break;
        case '>': r += QStringLiteral("&gt;"); break;
        case '"': r += QStringLiteral("&quot;"); break;
        case '\'': r += QStringLiteral("&#39;"); break;
        default:  r += c;
        }
    }
    return r;
}

QString applyInline(const QString &line)
{
    QString work = escapeHtml(line);
    static const QRegularExpression codeRe(QStringLiteral("`([^`]+)`"));
    work.replace(codeRe, QStringLiteral("<code>\\1</code>"));
    static const QRegularExpression boldRe(QStringLiteral("\\*\\*([^*]+)\\*\\*"));
    work.replace(boldRe, QStringLiteral("<strong>\\1</strong>"));
    static const QRegularExpression italicRe(QStringLiteral("\\*([^*]+)\\*"));
    work.replace(italicRe, QStringLiteral("<em>\\1</em>"));
    static const QRegularExpression linkRe(QStringLiteral("\\[([^\\]]+)\\]\\(([^\\)]+)\\)"));
    work.replace(linkRe, QStringLiteral("<a href=\"\\2\">\\1</a>"));
    return work;
}

bool markdownToHtml(const QString &inputPath, const QString &outputPath, QString *errorOut)
{
    QFile in(inputPath);
    if (!in.open(QIODevice::ReadOnly | QIODevice::Text)) {
        if (errorOut) *errorOut = QStringLiteral("Не удалось открыть Markdown");
        return false;
    }
    QTextStream rs(&in);
    rs.setEncoding(QStringConverter::Utf8);
    const QStringList lines = rs.readAll().split('\n');
    in.close();

    QString body;
    body.reserve(8192);
    bool inCode = false;
    bool inList = false;
    QStringList paragraph;

    auto flushParagraph = [&]() {
        if (paragraph.isEmpty()) return;
        body += QStringLiteral("    <p>") + paragraph.join(' ') + QStringLiteral("</p>\n");
        paragraph.clear();
    };

    auto flushList = [&]() {
        if (inList) {
            body += QStringLiteral("    </ul>\n");
            inList = false;
        }
    };

    for (const QString &raw : lines) {
        QString line = raw;
        if (line.endsWith('\r')) line.chop(1);

        if (line.startsWith(QStringLiteral("```"))) {
            flushParagraph();
            flushList();
            if (!inCode) {
                body += QStringLiteral("    <pre><code>");
                inCode = true;
            } else {
                body += QStringLiteral("</code></pre>\n");
                inCode = false;
            }
            continue;
        }
        if (inCode) {
            body += escapeHtml(line) + '\n';
            continue;
        }
        if (line.trimmed().isEmpty()) {
            flushParagraph();
            flushList();
            continue;
        }
        if (line.startsWith(QStringLiteral("# "))) {
            flushParagraph(); flushList();
            body += QStringLiteral("    <h1>") + applyInline(line.mid(2)) + QStringLiteral("</h1>\n");
            continue;
        }
        if (line.startsWith(QStringLiteral("## "))) {
            flushParagraph(); flushList();
            body += QStringLiteral("    <h2>") + applyInline(line.mid(3)) + QStringLiteral("</h2>\n");
            continue;
        }
        if (line.startsWith(QStringLiteral("### "))) {
            flushParagraph(); flushList();
            body += QStringLiteral("    <h3>") + applyInline(line.mid(4)) + QStringLiteral("</h3>\n");
            continue;
        }
        if (line.startsWith(QStringLiteral("- ")) || line.startsWith(QStringLiteral("* "))) {
            flushParagraph();
            if (!inList) {
                body += QStringLiteral("    <ul>\n");
                inList = true;
            }
            body += QStringLiteral("        <li>") + applyInline(line.mid(2)) + QStringLiteral("</li>\n");
            continue;
        }
        if (line.startsWith(QStringLiteral("> "))) {
            flushParagraph(); flushList();
            body += QStringLiteral("    <blockquote>") + applyInline(line.mid(2)) + QStringLiteral("</blockquote>\n");
            continue;
        }
        flushList();
        paragraph << applyInline(line);
    }
    flushParagraph();
    flushList();
    if (inCode) body += QStringLiteral("</code></pre>\n");

    QFile out(outputPath);
    if (!out.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
        if (errorOut) *errorOut = QStringLiteral("Не удалось открыть HTML");
        return false;
    }
    QTextStream ws(&out);
    ws.setEncoding(QStringConverter::Utf8);
    ws << "<!doctype html>\n<html lang=\"ru\">\n<head>\n"
       << "  <meta charset=\"utf-8\">\n"
       << "  <title>" << escapeHtml(QFileInfo(inputPath).completeBaseName()) << "</title>\n"
       << "  <style>body{font-family:system-ui,Segoe UI,sans-serif;max-width:760px;margin:48px auto;padding:0 20px;color:#1f2937;line-height:1.6}"
       << "code{background:#f3f4f6;padding:2px 6px;border-radius:4px;font-family:ui-monospace,Consolas,monospace}"
       << "pre{background:#0f172a;color:#e5e7eb;padding:14px;border-radius:8px;overflow:auto}"
       << "blockquote{border-left:3px solid #f59e0b;background:#fffbeb;padding:8px 14px;margin:12px 0;color:#374151}"
       << "h1,h2,h3{color:#111827}a{color:#d97706}</style>\n"
       << "</head>\n<body>\n" << body << "</body>\n</html>\n";
    out.close();
    return true;
}

} // anonymous namespace

QStringList DataConverter::supportedModes()
{
    return {
        QStringLiteral("CSV → JSON"),
        QStringLiteral("JSON → CSV"),
        QStringLiteral("Markdown → HTML"),
    };
}

bool DataConverter::convert(const QString &inputPath,
                            const QString &outputPath,
                            const QString &mode,
                            QString *errorOut)
{
    if (mode == QStringLiteral("CSV → JSON")) {
        return csvToJson(inputPath, outputPath, errorOut);
    }
    if (mode == QStringLiteral("JSON → CSV")) {
        return jsonToCsv(inputPath, outputPath, errorOut);
    }
    if (mode == QStringLiteral("Markdown → HTML")) {
        return markdownToHtml(inputPath, outputPath, errorOut);
    }
    if (errorOut) *errorOut = QStringLiteral("Неизвестный режим: %1").arg(mode);
    return false;
}

#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QUrl>
#include <QVariantList>

class ConverterController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastMessage READ lastMessage NOTIFY lastMessageChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:
    explicit ConverterController(QObject *parent = nullptr);

    QString lastMessage() const { return m_lastMessage; }
    bool busy() const { return m_busy; }

    Q_INVOKABLE QStringList encodingFormats() const;
    Q_INVOKABLE QStringList imageFormats() const;
    Q_INVOKABLE QStringList dataFormats() const;
    Q_INVOKABLE QStringList encodeFormats() const;
    Q_INVOKABLE QStringList videoModes() const;
    Q_INVOKABLE bool ffmpegAvailable() const;

    Q_INVOKABLE QString toLocalPath(const QUrl &url) const;
    Q_INVOKABLE QString suggestOutputPath(const QString &inputPath, const QString &targetExt) const;
    Q_INVOKABLE QString fileSizeHuman(const QString &path) const;
    Q_INVOKABLE QString detectEncoding(const QString &inputPath) const;

    Q_INVOKABLE bool convertEncoding(const QString &inputPath,
                                     const QString &outputPath,
                                     const QString &fromEncoding,
                                     const QString &toEncoding);

    Q_INVOKABLE bool convertImage(const QString &inputPath,
                                  const QString &outputPath,
                                  const QString &targetFormat,
                                  int quality);

    Q_INVOKABLE bool convertData(const QString &inputPath,
                                 const QString &outputPath,
                                 const QString &mode);

    Q_INVOKABLE bool convertEncode(const QString &inputPath,
                                   const QString &outputPath,
                                   const QString &mode);

    Q_INVOKABLE bool convertVideo(const QString &inputPath,
                                  const QString &outputPath,
                                  const QString &mode,
                                  int durationSec,
                                  int fps,
                                  int maxWidth);

signals:
    void lastMessageChanged();
    void busyChanged();
    void conversionFinished(bool success, const QString &outputPath, const QString &message);

private:
    void setBusy(bool busy);
    void emitFinished(bool success, const QString &outputPath, const QString &message);

    QString m_lastMessage;
    bool m_busy = false;
};

#pragma once

#include <QObject>
#include <QColor>
#include <QString>
#include <QTimer>

// Application-wide theme. Exposed to QML as the context property `theme`.
//
// mode is one of: "dark", "light", "snow", "rgb"
//   - "dark"  — graphite floor + amber chromatic accent
//   - "light" — warm off-white floor + amber chromatic accent
//   - "snow"  — pure white floor (no warm tint), neutral grays + amber accent
//   - "rgb"   — dark graphite floor + accent hue cycles through the wheel
class Theme : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(bool dark READ isDark NOTIFY modeChanged)
    Q_PROPERTY(bool rgb READ isRgb NOTIFY modeChanged)

    Q_PROPERTY(QColor bg            READ bg            NOTIFY paletteChanged)
    Q_PROPERTY(QColor bgGradTop     READ bgGradTop     NOTIFY paletteChanged)
    Q_PROPERTY(QColor bgGradBottom  READ bgGradBottom  NOTIFY paletteChanged)
    Q_PROPERTY(QColor sidebarBg     READ sidebarBg     NOTIFY paletteChanged)
    Q_PROPERTY(QColor surface       READ surface       NOTIFY paletteChanged)
    Q_PROPERTY(QColor surfaceHover  READ surfaceHover  NOTIFY paletteChanged)
    Q_PROPERTY(QColor border        READ border        NOTIFY paletteChanged)
    Q_PROPERTY(QColor divider       READ divider       NOTIFY paletteChanged)

    Q_PROPERTY(QColor accent        READ accent        NOTIFY paletteChanged)
    Q_PROPERTY(QColor accentHover   READ accentHover   NOTIFY paletteChanged)
    Q_PROPERTY(QColor accentDeep    READ accentDeep    NOTIFY paletteChanged)
    Q_PROPERTY(QColor accentSoft    READ accentSoft    NOTIFY paletteChanged)
    Q_PROPERTY(QColor accentTextOn  READ accentTextOn  NOTIFY paletteChanged)

    Q_PROPERTY(QColor textPrimary   READ textPrimary   NOTIFY paletteChanged)
    Q_PROPERTY(QColor textSecondary READ textSecondary NOTIFY paletteChanged)
    Q_PROPERTY(QColor textMuted     READ textMuted     NOTIFY paletteChanged)

    Q_PROPERTY(QColor success READ success CONSTANT)
    Q_PROPERTY(QColor error   READ error   CONSTANT)

    Q_PROPERTY(int rgbPeriodMs READ rgbPeriodMs WRITE setRgbPeriodMs NOTIFY rgbPeriodChanged)

public:
    explicit Theme(QObject *parent = nullptr);

    QString mode() const { return m_mode; }
    void setMode(const QString &m);
    bool isDark() const  { return m_mode != QStringLiteral("light")
                                && m_mode != QStringLiteral("snow"); }
    bool isLight() const { return m_mode == QStringLiteral("light"); }
    bool isSnow() const  { return m_mode == QStringLiteral("snow"); }
    bool isRgb() const   { return m_mode == QStringLiteral("rgb"); }

    QColor bg() const;
    QColor bgGradTop() const;
    QColor bgGradBottom() const;
    QColor sidebarBg() const;
    QColor surface() const;
    QColor surfaceHover() const;
    QColor border() const;
    QColor divider() const;

    QColor accent() const;
    QColor accentHover() const;
    QColor accentDeep() const;
    QColor accentSoft() const;
    QColor accentTextOn() const; // foreground that reads well on accent

    QColor textPrimary() const;
    QColor textSecondary() const;
    QColor textMuted() const;

    QColor success() const { return QColor("#22C55E"); }
    QColor error() const   { return QColor("#F43F5E"); }

    int rgbPeriodMs() const { return m_rgbPeriodMs; }
    void setRgbPeriodMs(int ms);

signals:
    void modeChanged();
    void paletteChanged();
    void rgbPeriodChanged();

private slots:
    void onRgbTick();

private:
    QString m_mode = QStringLiteral("dark");

    // RGB cycle state
    QTimer m_rgbTimer;
    qreal  m_rgbHue = 0.10; // 0..1 -- start near amber
    int    m_rgbPeriodMs = 6000; // full cycle in ms

    QColor amber() const { return QColor(245, 158, 11); }
};

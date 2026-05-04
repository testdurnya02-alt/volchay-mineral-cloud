#include "Theme.h"

#include <QSettings>

namespace {

// In RGB mode the accent hue is m_rgbHue; we keep saturation/lightness
// roughly matching amber's vivid feel so the UI doesn't go pastel or
// neon depending on which hue we're on.
constexpr qreal kRgbSaturation = 0.86;
constexpr qreal kRgbLightness  = 0.52;

} // namespace

Theme::Theme(QObject *parent)
    : QObject(parent)
{
    m_rgbTimer.setInterval(50); // 20 fps cycle
    connect(&m_rgbTimer, &QTimer::timeout, this, &Theme::onRgbTick);

    // Restore previously chosen theme/period (org+app set in main.cpp)
    QSettings s;
    const QString savedMode = s.value(QStringLiteral("theme/mode"),
                                      QStringLiteral("dark")).toString();
    m_rgbPeriodMs = s.value(QStringLiteral("theme/rgbPeriodMs"), m_rgbPeriodMs).toInt();
    if (savedMode == QStringLiteral("light")
        || savedMode == QStringLiteral("snow")
        || savedMode == QStringLiteral("rgb")
        || savedMode == QStringLiteral("dark")) {
        m_mode = savedMode;
    }
    if (isRgb()) m_rgbTimer.start();
}

void Theme::setMode(const QString &m)
{
    if (m == m_mode) return;
    m_mode = m;
    if (isRgb()) {
        m_rgbTimer.start();
    } else {
        m_rgbTimer.stop();
    }
    QSettings().setValue(QStringLiteral("theme/mode"), m_mode);
    emit modeChanged();
    emit paletteChanged();
}

void Theme::setRgbPeriodMs(int ms)
{
    if (ms < 500) ms = 500;
    if (ms > 60000) ms = 60000;
    if (ms == m_rgbPeriodMs) return;
    m_rgbPeriodMs = ms;
    QSettings().setValue(QStringLiteral("theme/rgbPeriodMs"), m_rgbPeriodMs);
    emit rgbPeriodChanged();
}

void Theme::onRgbTick()
{
    // Advance hue by (interval / period) of a full revolution
    const qreal delta = qreal(m_rgbTimer.interval()) / qreal(m_rgbPeriodMs);
    m_rgbHue += delta;
    if (m_rgbHue >= 1.0) m_rgbHue -= 1.0;
    emit paletteChanged();
}

// ---------------- BACKGROUND / SURFACE ----------------
//
// Snow is intentionally monochrome (white + light gray, no warm tint).
// In RGB mode the floor gets a tiny tint pulled from the cycling accent
// so the whole window visibly “breathes” the colour, not just the buttons.

QColor Theme::bg() const
{
    if (isLight()) return QColor("#F4F2EE");
    if (isSnow())  return QColor("#FFFFFF");
    return QColor("#0E0D11");
}

QColor Theme::bgGradTop() const
{
    if (isLight()) return QColor("#FAF8F3");
    if (isSnow())  return QColor("#FFFFFF");
    if (isRgb()) {
        // Dark base + faint accent tint in the top half.
        QColor a = accent();
        return QColor::fromRgbF(0.082 + a.redF()   * 0.07,
                                0.078 + a.greenF() * 0.07,
                                0.102 + a.blueF()  * 0.07);
    }
    return QColor("#15141A");
}

QColor Theme::bgGradBottom() const
{
    if (isLight()) return QColor("#E6E2D9");
    if (isSnow())  return QColor("#F2F2F2");
    if (isRgb()) {
        QColor a = accent();
        return QColor::fromRgbF(0.030 + a.redF()   * 0.05,
                                0.027 + a.greenF() * 0.05,
                                0.040 + a.blueF()  * 0.05);
    }
    return QColor("#08070A");
}

QColor Theme::sidebarBg() const
{
    if (isDark()) return QColor::fromRgbF(1, 1, 1, 0.025);
    if (isSnow()) return QColor("#F4F4F5");      // solid light gray rail
    return QColor::fromRgbF(0, 0, 0, 0.04);
}

QColor Theme::surface() const
{
    if (isDark()) return QColor::fromRgbF(1, 1, 1, 0.045);
    if (isSnow()) return QColor("#EFEFF1");      // solid light gray card on white
    return QColor::fromRgbF(0, 0, 0, 0.04);
}

QColor Theme::surfaceHover() const
{
    if (isDark()) return QColor::fromRgbF(1, 1, 1, 0.075);
    if (isSnow()) return QColor("#E4E4E7");
    return QColor::fromRgbF(0, 0, 0, 0.07);
}

QColor Theme::border() const
{
    if (isDark()) return QColor::fromRgbF(1, 1, 1, 0.09);
    if (isSnow()) return QColor("#D4D4D8");      // visible neutral gray edge
    return QColor::fromRgbF(0, 0, 0, 0.10);
}

QColor Theme::divider() const
{
    if (isDark()) return QColor::fromRgbF(1, 1, 1, 0.06);
    if (isSnow()) return QColor("#E4E4E7");
    return QColor::fromRgbF(0, 0, 0, 0.07);
}

// ---------------- ACCENT ----------------

QColor Theme::accent() const
{
    if (isRgb()) {
        return QColor::fromHslF(m_rgbHue, kRgbSaturation, kRgbLightness);
    }
    if (isSnow()) {
        // Snow theme is monochrome — accent is a bright neutral gray.
        return QColor("#6B7280");
    }
    return amber();
}

QColor Theme::accentHover() const
{
    QColor a = accent();
    return a.lighter(115);
}

QColor Theme::accentDeep() const
{
    QColor a = accent();
    return a.darker(125);
}

QColor Theme::accentSoft() const
{
    QColor a = accent();
    a.setAlphaF(0.18);
    return a;
}

QColor Theme::accentTextOn() const
{
    // Most accent backgrounds are vivid mid-saturation; dark text is most
    // readable across the wheel except for very dark blues — keep it dark
    // for amber and most others, and switch to white only for very dark hues.
    QColor a = accent();
    float h, s, l, alpha;
    a.getHslF(&h, &s, &l, &alpha);
    return l < 0.4f ? QColor("#F2F1ED") : QColor("#1A1612");
}

// ---------------- TEXT ----------------

QColor Theme::textPrimary() const
{
    if (isDark()) return QColor("#F2F1ED");
    if (isSnow()) return QColor("#3A3A3D");   // medium-dark neutral gray, not black
    return QColor("#1A1612");
}

QColor Theme::textSecondary() const
{
    if (isDark()) return QColor("#A8A39A");
    if (isSnow()) return QColor("#6E6E72");
    return QColor("#5C564D");
}

QColor Theme::textMuted() const
{
    if (isDark()) return QColor("#6F6B63");
    if (isSnow()) return QColor("#9C9CA0");
    return QColor("#9A958B");
}

import QtQuick
import Qt5Compat.GraphicalEffects

// Theme-aware Acrylic backdrop:
//   - vertical gradient floor (palette comes from theme.bgGradTop/Bottom)
//   - faint accent glow (only on dark/rgb)
//   - cool top-left highlight (only on dark/rgb; dim on light; off on snow)
//   - very faint surface noise (only on dark)
//   - top highlight rim + bottom vignette
Item {
    id: root
    anchors.fill: parent

    // (1) Floor gradient pulled from the theme
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: theme.bgGradTop }
            GradientStop { position: 1.0; color: theme.bgGradBottom }
        }
    }

    // (2) Distant warm horizon glow — only meaningful on dark backgrounds.
    //     Skipped entirely on light/snow themes where it would show as a band.
    Item {
        id: horizon
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        visible: false

        Rectangle {
            x: -parent.width * 0.20
            y: parent.height * 0.78
            width: parent.width * 1.60
            height: parent.height * 0.50
            radius: height / 2
            color: {
                const a = theme.accent
                return Qt.rgba(a.r, a.g, a.b, 0.10)
            }
        }
    }
    FastBlur {
        anchors.fill: horizon
        source: horizon
        radius: 128
        opacity: theme.dark ? 0.55 : 0.0
        visible: theme.dark
    }

    // (3) Top-left cool highlight — dark only
    Item {
        id: cool
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        visible: false

        Rectangle {
            x: -parent.width * 0.10
            y: -parent.height * 0.30
            width: parent.width * 0.90
            height: parent.height * 0.80
            radius: width / 2
            color: Qt.rgba(0.78, 0.84, 0.95, 0.045)
        }
    }
    FastBlur {
        anchors.fill: cool
        source: cool
        radius: 160
        opacity: theme.dark ? 0.7 : 0.0
        visible: theme.dark
    }

    // (4) Subtle scanline grain — only on dark themes (otherwise visible bands)
    Item {
        anchors.fill: parent
        opacity: 0.035
        visible: theme.dark
        Repeater {
            model: 80
            Rectangle {
                width: parent.width
                height: 1
                y: index * (parent.height / 80)
                color: index % 2 === 0 ? "#FFFFFF" : "transparent"
            }
        }
    }

    // (5) Top edge soft highlight rim
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: theme.dark ? Qt.rgba(1, 1, 1, 0.05)
                          : Qt.rgba(0, 0, 0, 0.08)
    }

    // (6) Bottom vignette — softer on light, none on snow
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, theme.dark ? 0.06 : 0.0) }
            GradientStop { position: 0.6; color: Qt.rgba(0, 0, 0, 0.00) }
            GradientStop {
                position: 1.0
                color: theme.dark ? Qt.rgba(0, 0, 0, 0.30)
                                  : (theme.mode === "snow" ? Qt.rgba(0, 0, 0, 0.0)
                                                           : Qt.rgba(0, 0, 0, 0.06))
            }
        }
    }
}

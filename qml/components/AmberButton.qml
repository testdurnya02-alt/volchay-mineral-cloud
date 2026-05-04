import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Button {
    id: btn
    property bool primary: true
    property int radius: 10

    implicitHeight: 36
    leftPadding: 18
    rightPadding: 18
    font.family: "Inter, Segoe UI, sans-serif"
    font.weight: Font.DemiBold
    font.pixelSize: 13

    background: Rectangle {
        radius: btn.radius
        color: !btn.primary ? theme.surface
              : btn.pressed ? theme.accentDeep
              : btn.hovered ? theme.accentHover
              : theme.accent
        border.width: btn.primary ? 0 : 1
        border.color: theme.border

        Behavior on color { ColorAnimation { duration: 120 } }

        Glow {
            anchors.fill: parent
            visible: btn.primary && (btn.hovered || btn.activeFocus)
            source: parent
            radius: 14
            color: theme.accent
            transparentBorder: true
            opacity: btn.pressed ? 0.6 : 0.85
            Behavior on opacity { NumberAnimation { duration: 140 } }
        }
    }

    contentItem: Text {
        text: btn.text
        color: btn.primary ? theme.accentTextOn : theme.textPrimary
        font: btn.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}

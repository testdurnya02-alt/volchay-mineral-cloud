import QtQuick
import QtQuick.Controls

Button {
    id: btn
    implicitHeight: 32
    leftPadding: 14
    rightPadding: 14
    font.family: "Inter, Segoe UI, sans-serif"
    font.pixelSize: 12
    font.weight: Font.Medium

    background: Rectangle {
        radius: 8
        color: btn.pressed ? theme.surfaceHover
              : btn.hovered ? theme.surface
              : "transparent"
        border.width: 1
        border.color: btn.hovered ? theme.accent : theme.border
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }
    contentItem: Text {
        text: btn.text
        color: theme.textPrimary
        font: btn.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}

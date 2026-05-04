import QtQuick
import QtQuick.Controls

Item {
    id: root
    property alias text: label.text
    property string glyph: "•"
    property bool active: false
    signal clicked()

    implicitHeight: 40

    Rectangle {
        id: bg
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        radius: 8
        color: root.active ? theme.accentSoft
              : ma.containsMouse ? theme.surface
              : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    // Active vertical accent bar
    Rectangle {
        anchors.left: bg.left
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: 18
        radius: 2
        color: theme.accent
        opacity: root.active ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
    }

    Row {
        anchors.fill: bg
        anchors.leftMargin: 18
        anchors.rightMargin: 12
        spacing: 12

        Text {
            id: glyphLabel
            text: root.glyph
            color: root.active ? theme.accent : theme.textSecondary
            font.pixelSize: 16
            font.family: "Inter, Segoe UI, sans-serif"
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            horizontalAlignment: Text.AlignHCenter
            Behavior on color { ColorAnimation { duration: 140 } }
        }
        Text {
            id: label
            color: root.active ? theme.textPrimary : theme.textSecondary
            font.family: "Inter, Segoe UI, sans-serif"
            font.pixelSize: 13
            font.weight: root.active ? Font.DemiBold : Font.Normal
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 140 } }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var model: []
    property int currentIndex: 0
    signal activated(int index, string value)

    implicitHeight: 36
    implicitWidth: row.implicitWidth

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: theme.surface
        border.width: 1
        border.color: theme.border
    }

    Row {
        id: row
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        Repeater {
            model: root.model
            Rectangle {
                required property var modelData
                required property int index
                height: parent.height
                width: Math.max(72, label.implicitWidth + 24)
                radius: 8
                color: index === root.currentIndex
                       ? theme.accentSoft
                       : ma.containsMouse ? theme.surfaceHover : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                border.width: index === root.currentIndex ? 1 : 0
                border.color: theme.accent

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: typeof modelData === "string" ? modelData : (modelData.label || "")
                    color: index === root.currentIndex ? theme.accent : theme.textSecondary
                    font.family: "Inter, Segoe UI, sans-serif"
                    font.pixelSize: 12
                    font.weight: index === root.currentIndex ? Font.DemiBold : Font.Normal
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentIndex = index
                        root.activated(index, typeof modelData === "string" ? modelData : (modelData.value || modelData.label || ""))
                    }
                }
            }
        }
    }
}

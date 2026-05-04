import QtQuick

Rectangle {
    id: root
    property string text: ""
    property bool success: true

    color: {
        const c = success ? theme.success : theme.error
        return Qt.rgba(c.r, c.g, c.b, 0.16)
    }
    border.width: 1
    border.color: {
        const c = success ? theme.success : theme.error
        return Qt.rgba(c.r, c.g, c.b, 0.50)
    }
    radius: 10
    height: text === "" ? 0 : 40
    visible: text !== ""
    clip: true
    Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.success ? "✓" : "!"
            color: root.success ? theme.success : theme.error
            font.pixelSize: 14
            font.weight: Font.Bold
            width: 14
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: theme.textPrimary
            font.family: "Inter, Segoe UI, sans-serif"
            font.pixelSize: 12
            elide: Text.ElideRight
        }
    }
}

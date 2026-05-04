import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property alias text: input.text
    property string placeholder: "Путь…"
    property bool readOnly: false
    signal clicked()

    height: 36
    radius: 10
    color: input.activeFocus ? theme.surfaceHover : theme.surface
    border.width: 1
    border.color: input.activeFocus ? theme.accent : theme.border
    Behavior on border.color { ColorAnimation { duration: 120 } }

    TextField {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        background: Item {}
        color: theme.textPrimary
        placeholderText: root.placeholder
        placeholderTextColor: theme.textMuted
        font.family: "Inter, Segoe UI, sans-serif"
        font.pixelSize: 12
        readOnly: root.readOnly
        verticalAlignment: TextInput.AlignVCenter
        selectionColor: theme.accentSoft
        selectedTextColor: theme.textPrimary
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.readOnly
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

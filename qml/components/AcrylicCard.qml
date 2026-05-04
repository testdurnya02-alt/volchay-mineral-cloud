import QtQuick

// Translucent panel with crisp 1px border + inner top highlight (acrylic feel).
// All colours come from the global `theme` context property so the card
// automatically restyles when the theme changes.
Rectangle {
    id: card
    color: theme.surface
    border.width: 1
    border.color: theme.border
    radius: 14
    antialiasing: true

    Behavior on color        { ColorAnimation { duration: 180 } }
    Behavior on border.color { ColorAnimation { duration: 180 } }

    // Inner top highlight — subtle glass edge
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 1
        height: 1
        color: theme.dark ? Qt.rgba(1, 1, 1, 0.10)
                          : Qt.rgba(1, 1, 1, 0.55)
    }
}

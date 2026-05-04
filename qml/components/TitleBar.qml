import QtQuick
import QtQuick.Window

Rectangle {
    id: root
    color: "transparent"
    height: 44

    property string title: "Volchay con Pro"
    property string subtitle: "Universal File Converter"
    signal minimizeRequested()
    signal maximizeRequested()
    signal closeRequested()

    // Drag the window — delegate to the OS via startSystemMove() so the move
    // is rendered by the compositor (no per-frame x/y bookkeeping in QML, which
    // visibly stutters). Falls back to manual movement on platforms where
    // startSystemMove() returns false (rare; mostly older Wayland setups).
    MouseArea {
        anchors.fill: parent
        anchors.rightMargin: 140
        cursorShape: Qt.SizeAllCursor
        property point startPos
        property point startWindowPos
        property bool nativeMove: false

        onPressed: function(mouse) {
            const w = root.Window.window
            nativeMove = false
            if (w && typeof w.startSystemMove === "function") {
                nativeMove = w.startSystemMove()
            }
            if (!nativeMove && w) {
                startPos = Qt.point(mouse.x, mouse.y)
                startWindowPos = Qt.point(w.x, w.y)
            }
        }
        onPositionChanged: function(mouse) {
            if (pressed && !nativeMove) {
                const w = root.Window.window
                if (w) {
                    w.x = startWindowPos.x + (mouse.x - startPos.x)
                    w.y = startWindowPos.y + (mouse.y - startPos.y)
                }
            }
        }
        onDoubleClicked: root.maximizeRequested()
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        AppLogo {
            width: 56
            height: 30
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: root.title
            color: theme.textPrimary
            font.family: "Inter, Segoe UI, sans-serif"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle {
            width: 1; height: 16; color: theme.divider
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: root.subtitle
            color: theme.textSecondary
            font.family: "Inter, Segoe UI, sans-serif"
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: [
                { glyph: "—", action: "min" },
                { glyph: "▢", action: "max" },
                { glyph: "✕", action: "close" }
            ]
            Rectangle {
                required property var modelData
                width: 38; height: 28; radius: 6
                color: ma.containsMouse
                       ? (modelData.action === "close" ? Qt.rgba(0.95, 0.25, 0.35, 0.85)
                                                       : theme.surfaceHover)
                       : "transparent"
                Behavior on color { ColorAnimation { duration: 110 } }
                Text {
                    anchors.centerIn: parent
                    text: modelData.glyph
                    color: theme.textPrimary
                    font.pixelSize: 12
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.action === "min") root.minimizeRequested()
                        else if (modelData.action === "max") root.maximizeRequested()
                        else root.closeRequested()
                    }
                }
            }
        }
    }
}

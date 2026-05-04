import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string filePath: ""
    property string hint: "Перетащи файл сюда или нажми, чтобы выбрать"
    property string sizeText: ""
    signal openRequested()
    signal cleared()

    radius: 14
    color: drop.containsDrag ? theme.accentSoft : theme.surface
    Behavior on color { ColorAnimation { duration: 140 } }

    // Dashed border
    Canvas {
        id: dashed
        anchors.fill: parent
        antialiasing: true
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = drop.containsDrag ? theme.accent.toString()
                                                 : theme.border.toString()
            ctx.lineWidth = drop.containsDrag ? 2 : 1.4
            ctx.setLineDash([8, 6])
            const r = 14
            const x = 1, y = 1
            const w = width - 2, h = height - 2
            ctx.beginPath()
            ctx.moveTo(x + r, y)
            ctx.arcTo(x + w, y, x + w, y + h, r)
            ctx.arcTo(x + w, y + h, x, y + h, r)
            ctx.arcTo(x, y + h, x, y, r)
            ctx.arcTo(x, y, x + w, y, r)
            ctx.closePath()
            ctx.stroke()
        }
        Connections {
            target: drop
            function onContainsDragChanged() { dashed.requestPaint() }
        }
    }

    DropArea {
        id: drop
        anchors.fill: parent
        onDropped: function(drop) {
            if (drop.hasUrls && drop.urls.length > 0) {
                root.filePath = drop.urls[0].toString().replace(/^file:\/\//, "")
                drop.acceptProposedAction()
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.openRequested()
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8
        visible: root.filePath === ""

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 56; height: 56; radius: 14
            color: theme.accentSoft
            border.width: 1
            border.color: theme.accent
            Text {
                anchors.centerIn: parent
                text: "↧"
                color: theme.accent
                font.pixelSize: 28
                font.weight: Font.Bold
            }
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.hint
            color: theme.textSecondary
            font.family: "Inter, Segoe UI, sans-serif"
            font.pixelSize: 13
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14
        visible: root.filePath !== ""

        Rectangle {
            Layout.preferredWidth: 44; Layout.preferredHeight: 44
            radius: 10
            color: theme.accentSoft
            border.width: 1
            border.color: theme.accent
            Text {
                anchors.centerIn: parent
                text: "📄"
                font.pixelSize: 22
            }
        }
        ColumnLayout {
            spacing: 2
            Layout.fillWidth: true
            Text {
                text: {
                    const p = root.filePath
                    const idx = Math.max(p.lastIndexOf('/'), p.lastIndexOf('\\'))
                    return idx >= 0 ? p.substring(idx + 1) : p
                }
                color: theme.textPrimary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                elide: Text.ElideMiddle
                Layout.fillWidth: true
            }
            Text {
                text: root.filePath + (root.sizeText ? "   ·   " + root.sizeText : "")
                color: theme.textMuted
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 11
                elide: Text.ElideMiddle
                Layout.fillWidth: true
            }
        }
        Rectangle {
            Layout.preferredWidth: 30; Layout.preferredHeight: 30
            radius: 8
            color: clearMa.containsMouse ? theme.surfaceHover : "transparent"
            border.width: 1
            border.color: theme.border
            Text { anchors.centerIn: parent; text: "✕"; color: theme.textSecondary; font.pixelSize: 12 }
            MouseArea {
                id: clearMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: { root.filePath = ""; root.cleared() }
            }
        }
    }
}

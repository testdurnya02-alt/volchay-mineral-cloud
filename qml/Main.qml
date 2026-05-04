import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "pages"

ApplicationWindow {
    id: window
    visible: true
    width: 1180
    height: 740
    minimumWidth: 880
    minimumHeight: 600
    title: "Volchay con Pro"
    color: theme.bg
    flags: Qt.Window | Qt.FramelessWindowHint

    property string currentPage: "home"
    // Reference to the C++ ConverterController (exposed as context property `converter`)
    property var controller: converter

    AcrylicBackground { id: backdrop }

    // Outer shell — gives the window a 1px highlight rim like Luna's polished frame
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: theme.divider
        radius: 0
        z: 1000
    }

    // Title bar
    TitleBar {
        id: titleBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        z: 5
        onMinimizeRequested: window.showMinimized()
        onMaximizeRequested: window.visibility === Window.Maximized
                              ? window.showNormal() : window.showMaximized()
        onCloseRequested: window.close()
    }

    // Subtle separator under the title bar
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: titleBar.bottom
        height: 1
        color: theme.divider
        z: 5
    }

    RowLayout {
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 1
        spacing: 0

        // Sidebar
        Rectangle {
            id: sidebar
            Layout.preferredWidth: 232
            Layout.fillHeight: true
            color: theme.sidebarBg
            border.width: 0
            // right divider
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: theme.divider
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 14
                spacing: 0

                Text {
                    Layout.leftMargin: 22
                    Layout.bottomMargin: 8
                    text: "БИБЛИОТЕКА"
                    color: theme.textMuted
                    font.family: "Inter, Segoe UI, sans-serif"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 1.4
                }

                SidebarItem {
                    Layout.fillWidth: true
                    glyph: "⌂"
                    text: "Главная"
                    active: window.currentPage === "home"
                    onClicked: window.currentPage = "home"
                }
                SidebarItem {
                    Layout.fillWidth: true
                    glyph: "Aa"
                    text: "Кодировки"
                    active: window.currentPage === "encodings"
                    onClicked: window.currentPage = "encodings"
                }
                SidebarItem {
                    Layout.fillWidth: true
                    glyph: "▦"
                    text: "Изображения"
                    active: window.currentPage === "images"
                    onClicked: window.currentPage = "images"
                }
                SidebarItem {
                    Layout.fillWidth: true
                    glyph: "≣"
                    text: "Данные"
                    active: window.currentPage === "data"
                    onClicked: window.currentPage = "data"
                }
                SidebarItem {
                    Layout.fillWidth: true
                    glyph: "01"
                    text: "Кодирование"
                    active: window.currentPage === "encode"
                    onClicked: window.currentPage = "encode"
                }
                SidebarItem {
                    Layout.fillWidth: true
                    glyph: "▷"
                    text: "Видео и GIF"
                    active: window.currentPage === "video"
                    onClicked: window.currentPage = "video"
                }
                SidebarItem {
                    Layout.fillWidth: true
                    glyph: "⚙"
                    text: "Настройки"
                    active: window.currentPage === "settings"
                    onClicked: window.currentPage = "settings"
                }

                Item { Layout.fillHeight: true }

                // Footer chip
                Item {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 14
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    height: 56
                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: theme.surface
                        border.width: 1
                        border.color: theme.border
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10
                        AppLogo {
                            Layout.preferredWidth: 56
                            Layout.preferredHeight: 30
                        }
                        ColumnLayout {
                            spacing: 0
                            Layout.fillWidth: true
                            Text {
                                text: "Volchay v0.1"
                                color: theme.textPrimary
                                font.family: "Inter, Segoe UI, sans-serif"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: "by Sasha"
                                color: theme.textMuted
                                font.family: "Inter, Segoe UI, sans-serif"
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
        }

        // Content area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StackLayout {
                id: stack
                anchors.fill: parent
                currentIndex: switch (window.currentPage) {
                              case "home": return 0
                              case "encodings": return 1
                              case "images": return 2
                              case "data": return 3
                              case "encode": return 4
                              case "video": return 5
                              case "settings": return 6
                              }

                HomePage {
                    onNavigate: function(target) { window.currentPage = target }
                }
                EncodingsPage { converter: window.controller }
                ImagesPage    { converter: window.controller }
                DataPage      { converter: window.controller }
                EncodePage    { converter: window.controller }
                VideoPage     { converter: window.controller }
                SettingsPage  {}
            }
        }
    }

    // Resize handle (bottom-right). Delegates to startSystemResize() so the
    // OS compositor handles the live resize — same reason as window dragging.
    MouseArea {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 16; height: 16
        cursorShape: Qt.SizeFDiagCursor
        property point startPos
        property size startSize
        property bool nativeResize: false
        onPressed: function(mouse) {
            nativeResize = false
            if (typeof window.startSystemResize === "function") {
                nativeResize = window.startSystemResize(Qt.BottomEdge | Qt.RightEdge)
            }
            if (!nativeResize) {
                startPos = window.mapToGlobal(mouse.x, mouse.y)
                startSize = Qt.size(window.width, window.height)
            }
        }
        onPositionChanged: function(mouse) {
            if (pressed && !nativeResize) {
                const cur = window.mapToGlobal(mouse.x, mouse.y)
                window.width = Math.max(window.minimumWidth, startSize.width + (cur.x - startPos.x))
                window.height = Math.max(window.minimumHeight, startSize.height + (cur.y - startPos.y))
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: page

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 18

        // Header
        ColumnLayout {
            spacing: 4
            Layout.fillWidth: true
            Text {
                text: "Настройки"
                color: theme.textPrimary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 26
                font.weight: Font.DemiBold
            }
            Text {
                text: "Внешний вид и тема приложения"
                color: theme.textSecondary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 13
            }
        }

        // Theme card
        AcrylicCard {
            Layout.fillWidth: true
            implicitHeight: themeCardLayout.implicitHeight + 40

            ColumnLayout {
                id: themeCardLayout
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                Text {
                    text: "Тема"
                    color: theme.textPrimary
                    font.family: "Inter, Segoe UI, sans-serif"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }
                Text {
                    text: "Выбери палитру интерфейса. RGB плавно меняет оттенок акцента по кругу."
                    color: theme.textSecondary
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    rowSpacing: 10
                    columnSpacing: 10

                    Repeater {
                        model: [
                            { mode: "dark",  title: "Dark",  subtitle: "Графит + янтарь",
                              top: "#15141A", bottom: "#0E0D11", swAccent: "#F59E0B", swRgb: false },
                            { mode: "light", title: "Light", subtitle: "Тёплый кремовый",
                              top: "#FAF8F3", bottom: "#E6E2D9", swAccent: "#F59E0B", swRgb: false },
                            { mode: "snow",  title: "Snow",  subtitle: "Чисто-белый",
                              top: "#FFFFFF", bottom: "#F2F2F2", swAccent: "#6B7280", swRgb: false },
                            { mode: "rgb",   title: "RGB",   subtitle: "Циклит акцент",
                              top: "#15141A", bottom: "#0E0D11", swAccent: "#F59E0B", swRgb: true }
                        ]
                        delegate: Item {
                            id: tile
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 130

                            readonly property bool selected: theme.mode === tile.modelData.mode

                            Rectangle {
                                anchors.fill: parent
                                radius: 12
                                color: tile.selected ? theme.surfaceHover : theme.surface
                                border.width: tile.selected ? 1.6 : 1
                                border.color: tile.selected ? theme.accent : theme.border

                                Behavior on border.color { ColorAnimation { duration: 140 } }
                                Behavior on color        { ColorAnimation { duration: 140 } }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8

                                Rectangle {
                                    id: swatch
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    radius: 8
                                    gradient: Gradient {
                                        orientation: Gradient.Vertical
                                        GradientStop { position: 0.0; color: tile.modelData.top }
                                        GradientStop { position: 1.0; color: tile.modelData.bottom }
                                    }
                                    border.width: 1
                                    border.color: theme.border

                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        anchors.margins: 6
                                        width: 16; height: 16; radius: 8
                                        color: tile.modelData.swRgb ? theme.accent
                                                                     : tile.modelData.swAccent
                                        border.width: 1
                                        border.color: Qt.rgba(0, 0, 0, 0.18)
                                    }
                                }

                                Text {
                                    text: tile.modelData.title
                                    color: theme.textPrimary
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: tile.modelData.subtitle
                                    color: theme.textSecondary
                                    font.pixelSize: 11
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: theme.mode = tile.modelData.mode
                            }
                        }
                    }
                }
            }
        }

        // RGB period card
        AcrylicCard {
            Layout.fillWidth: true
            implicitHeight: rgbCardLayout.implicitHeight + 40
            opacity: theme.rgb ? 1.0 : 0.55
            Behavior on opacity { NumberAnimation { duration: 180 } }

            ColumnLayout {
                id: rgbCardLayout
                anchors.fill: parent
                anchors.margins: 20
                spacing: 8

                Text {
                    text: "Скорость RGB-цикла"
                    color: theme.textPrimary
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }
                Text {
                    text: "Время одного полного оборота по цветовому кругу"
                    color: theme.textSecondary
                    font.pixelSize: 11
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Slider {
                        id: rgbSlider
                        Layout.fillWidth: true
                        from: 1000
                        to: 20000
                        stepSize: 250
                        value: theme.rgbPeriodMs
                        onMoved: theme.rgbPeriodMs = value
                        enabled: theme.rgb

                        background: Rectangle {
                            x: rgbSlider.leftPadding
                            y: rgbSlider.topPadding + rgbSlider.availableHeight / 2 - height / 2
                            width: rgbSlider.availableWidth
                            height: 4
                            radius: 2
                            color: theme.surface
                            Rectangle {
                                width: rgbSlider.visualPosition * parent.width
                                height: parent.height
                                color: theme.accent
                                radius: 2
                            }
                        }
                        handle: Rectangle {
                            x: rgbSlider.leftPadding + rgbSlider.visualPosition * (rgbSlider.availableWidth - width)
                            y: rgbSlider.topPadding + rgbSlider.availableHeight / 2 - height / 2
                            width: 16; height: 16; radius: 8
                            color: theme.accent
                            border.width: 2
                            border.color: theme.bg
                        }
                    }
                    Text {
                        text: (theme.rgbPeriodMs / 1000).toFixed(1) + " с"
                        color: theme.textPrimary
                        font.family: "JetBrains Mono, Cascadia Code, monospace"
                        font.pixelSize: 13
                        Layout.preferredWidth: 56
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        // About card
        AcrylicCard {
            Layout.fillWidth: true
            implicitHeight: aboutLayout.implicitHeight + 40

            RowLayout {
                id: aboutLayout
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                AppLogo {
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 60
                }
                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true
                    Text {
                        text: "Volchay con Pro"
                        color: theme.textPrimary
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: "Универсальный конвертер файлов · v0.1.0 · Qt 6 / QML"
                        color: theme.textSecondary
                        font.pixelSize: 12
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}

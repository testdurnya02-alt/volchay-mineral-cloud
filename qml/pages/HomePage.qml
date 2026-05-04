import QtQuick
import QtQuick.Layouts
import "../components"

Item {
    id: page
    signal navigate(string target)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 20

        ColumnLayout {
            spacing: 6
            Layout.fillWidth: true
            Text {
                text: "Volchay con Pro"
                color: theme.textPrimary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 32
                font.weight: Font.Bold
            }
            Text {
                text: "Универсальный конвертер файлов"
                color: theme.textSecondary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 14
            }
        }

        GridLayout {
            columns: 2
            columnSpacing: 16
            rowSpacing: 16
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                model: [
                    { glyph: "Aa", label: "Кодировки", desc: "UTF-8 ↔ UTF-16 ↔ Win-1251 ↔ KOI8-R и др.", target: "encodings" },
                    { glyph: "▦",  label: "Изображения", desc: "PNG · JPG · BMP · WEBP · TIFF · ICO", target: "images" },
                    { glyph: "≣",  label: "Данные", desc: "CSV ↔ JSON · Markdown → HTML", target: "data" },
                    { glyph: "01", label: "Кодирование", desc: "Base64 и Hex: encode / decode", target: "encode" },
                    { glyph: "▷",  label: "Видео и GIF", desc: "Изображение ↔ MP4 ↔ GIF (через ffmpeg)", target: "video" },
                ]
                AcrylicCard {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitHeight: 160

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: page.navigate(modelData.target)
                        onContainsMouseChanged: parent.color = containsMouse
                            ? theme.surfaceHover : theme.surface
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 22
                        spacing: 10

                        Rectangle {
                            width: 48; height: 48; radius: 12
                            color: theme.accentSoft
                            border.width: 1
                            border.color: theme.accent
                            Text {
                                anchors.centerIn: parent
                                text: modelData.glyph
                                color: theme.accent
                                font.family: "Inter, Segoe UI, sans-serif"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }
                        }
                        Text {
                            text: modelData.label
                            color: theme.textPrimary
                            font.family: "Inter, Segoe UI, sans-serif"
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: modelData.desc
                            color: theme.textSecondary
                            font.family: "Inter, Segoe UI, sans-serif"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        Item { Layout.fillHeight: true }
                        Row {
                            spacing: 6
                            Text {
                                text: "Открыть"
                                color: theme.accent
                                font.family: "Inter, Segoe UI, sans-serif"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: "→"
                                color: theme.accent
                                font.family: "Inter, Segoe UI, sans-serif"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }
        }
    }
}

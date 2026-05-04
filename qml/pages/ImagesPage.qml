import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import "../components"

Item {
    id: page
    property var converter: null

    property string inputPath: ""
    property string outputPath: ""
    property var formats: converter ? converter.imageFormats() : []
    property int targetIdx: 0
    property int quality: 92
    property string lastResultText: ""
    property bool lastSuccess: true

    FileDialog {
        id: openDialog
        title: "Выбери изображение"
        nameFilters: ["Изображения (*.png *.jpg *.jpeg *.bmp *.webp *.tiff *.tif *.gif *.ico *.ppm *.xbm)", "Все файлы (*)"]
        onAccepted: {
            page.inputPath = converter.toLocalPath(selectedFile)
            const ext = "." + page.formats[page.targetIdx].toLowerCase()
            page.outputPath = converter.suggestOutputPath(page.inputPath, ext)
        }
    }
    FileDialog {
        id: saveDialog
        title: "Сохранить как"
        fileMode: FileDialog.SaveFile
        onAccepted: page.outputPath = converter.toLocalPath(selectedFile)
    }

    function refreshOutputExt() {
        if (!page.inputPath || !page.formats.length) return
        const ext = "." + page.formats[page.targetIdx].toLowerCase()
        page.outputPath = converter.suggestOutputPath(page.inputPath, ext)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 18

        ColumnLayout {
            spacing: 4
            Text {
                text: "Изображения"
                color: theme.textPrimary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 24
                font.weight: Font.Bold
            }
            Text {
                text: "Перекодируй между PNG, JPG, BMP, WEBP, TIFF и др."
                color: theme.textSecondary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 13
            }
        }

        AcrylicCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 150

            DropZone {
                anchors.fill: parent
                anchors.margins: 14
                filePath: page.inputPath
                sizeText: page.inputPath ? converter.fileSizeHuman(page.inputPath) : ""
                onOpenRequested: openDialog.open()
                onCleared: { page.inputPath = ""; page.outputPath = "" }
                onFilePathChanged: {
                    if (filePath !== page.inputPath) {
                        page.inputPath = filePath
                        page.refreshOutputExt()
                    }
                }
            }
        }

        AcrylicCard {
            Layout.fillWidth: true
            Layout.preferredHeight: parametersCol.implicitHeight + 36

            ColumnLayout {
                id: parametersCol
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                ColumnLayout {
                    spacing: 6
                    Layout.fillWidth: true
                    Text {
                        text: "Целевой формат"
                        color: theme.textSecondary
                        font.family: "Inter, Segoe UI, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                    SegmentedSelector {
                        Layout.fillWidth: true
                        model: page.formats
                        currentIndex: page.targetIdx
                        onActivated: function(index, value) {
                            page.targetIdx = index
                            page.refreshOutputExt()
                        }
                    }
                }

                ColumnLayout {
                    spacing: 6
                    Layout.fillWidth: true
                    Text {
                        text: "Качество (для JPG / WEBP)"
                        color: theme.textSecondary
                        font.family: "Inter, Segoe UI, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                    RowLayout {
                        spacing: 12
                        Layout.fillWidth: true
                        Slider {
                            id: qSlider
                            Layout.fillWidth: true
                            from: 1; to: 100
                            value: page.quality
                            onMoved: page.quality = Math.round(value)
                            background: Rectangle {
                                x: qSlider.leftPadding
                                y: qSlider.topPadding + qSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 6
                                width: qSlider.availableWidth
                                height: implicitHeight
                                radius: 3
                                color: Qt.rgba(1,1,1,0.08)
                                Rectangle {
                                    width: qSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: theme.accent
                                    radius: 3
                                }
                            }
                            handle: Rectangle {
                                x: qSlider.leftPadding + qSlider.visualPosition * (qSlider.availableWidth - width)
                                y: qSlider.topPadding + qSlider.availableHeight / 2 - height / 2
                                implicitWidth: 18; implicitHeight: 18
                                radius: 9
                                color: qSlider.pressed ? theme.accentHover : theme.accent
                                border.width: 2
                                border.color: theme.bg
                            }
                        }
                        Text {
                            text: page.quality + " %"
                            color: theme.accent
                            font.family: "Inter, Segoe UI, sans-serif"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            Layout.preferredWidth: 50
                        }
                    }
                }

                ColumnLayout {
                    spacing: 6
                    Layout.fillWidth: true
                    Text {
                        text: "Сохранить как"
                        color: theme.textSecondary
                        font.family: "Inter, Segoe UI, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                    RowLayout {
                        spacing: 8
                        Layout.fillWidth: true
                        PathField {
                            Layout.fillWidth: true
                            text: page.outputPath
                            placeholder: "Выбери файл…"
                            onTextChanged: page.outputPath = text
                        }
                        GhostButton {
                            text: "Обзор"
                            onClicked: saveDialog.open()
                        }
                    }
                }
            }
        }

        StatusToast {
            Layout.fillWidth: true
            text: page.lastResultText
            success: page.lastSuccess
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }
            AmberButton {
                text: "Конвертировать"
                enabled: page.inputPath !== "" && page.outputPath !== "" && page.formats.length > 0
                onClicked: {
                    const ok = converter.convertImage(
                        page.inputPath, page.outputPath,
                        page.formats[page.targetIdx], page.quality)
                    page.lastSuccess = ok
                    page.lastResultText = converter.lastMessage
                }
            }
        }
    }
}

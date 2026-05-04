import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

Item {
    id: page
    property var converter: null

    property string inputPath: ""
    property string outputPath: ""
    property var encodings: converter ? converter.encodingFormats() : []
    property int fromIdx: 0
    property int toIdx: 0
    property string lastResultText: ""
    property bool lastSuccess: true

    FileDialog {
        id: openDialog
        title: "Выбери исходный текстовый файл"
        nameFilters: ["Текстовые файлы (*.txt *.csv *.json *.md *.log *.html *.xml *.srt *.ini *.cfg *.yaml *.yml)", "Все файлы (*)"]
        onAccepted: {
            page.inputPath = converter.toLocalPath(selectedFile)
            const detected = converter.detectEncoding(page.inputPath)
            const idx = encodings.indexOf(detected)
            if (idx >= 0) page.fromIdx = idx
            const ext = ".txt"
            page.outputPath = converter.suggestOutputPath(page.inputPath, ext)
        }
    }
    FileDialog {
        id: saveDialog
        title: "Куда сохранить результат?"
        fileMode: FileDialog.SaveFile
        defaultSuffix: "txt"
        onAccepted: page.outputPath = converter.toLocalPath(selectedFile)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 18

        ColumnLayout {
            spacing: 4
            Text {
                text: "Кодировки текста"
                color: theme.textPrimary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 24
                font.weight: Font.Bold
            }
            Text {
                text: "Перекодируй текстовый файл из одной кодировки в другую"
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
                        const detected = converter.detectEncoding(page.inputPath)
                        const idx = page.encodings.indexOf(detected)
                        if (idx >= 0) page.fromIdx = idx
                        page.outputPath = converter.suggestOutputPath(page.inputPath, ".txt")
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

                RowLayout {
                    spacing: 18
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 6
                        Layout.fillWidth: true
                        Text {
                            text: "Из кодировки"
                            color: theme.textSecondary
                            font.family: "Inter, Segoe UI, sans-serif"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                        SegmentedSelector {
                            Layout.fillWidth: true
                            model: page.encodings
                            currentIndex: page.fromIdx
                            onActivated: function(index, value) { page.fromIdx = index }
                        }
                    }
                }

                RowLayout {
                    spacing: 18
                    Layout.fillWidth: true
                    ColumnLayout {
                        spacing: 6
                        Layout.fillWidth: true
                        Text {
                            text: "В кодировку"
                            color: theme.textSecondary
                            font.family: "Inter, Segoe UI, sans-serif"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                        SegmentedSelector {
                            Layout.fillWidth: true
                            model: page.encodings
                            currentIndex: page.toIdx
                            onActivated: function(index, value) { page.toIdx = index }
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
                enabled: page.inputPath !== "" && page.outputPath !== "" && page.encodings.length > 0
                onClicked: {
                    const ok = converter.convertEncoding(
                        page.inputPath, page.outputPath,
                        page.encodings[page.fromIdx],
                        page.encodings[page.toIdx])
                    page.lastSuccess = ok
                    page.lastResultText = converter.lastMessage
                }
            }
        }
    }
}

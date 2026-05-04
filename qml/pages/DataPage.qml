import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

Item {
    id: page
    property var converter: null

    property string inputPath: ""
    property string outputPath: ""
    property var modes: converter ? converter.dataFormats() : []
    property int modeIdx: 0
    property string lastResultText: ""
    property bool lastSuccess: true

    function targetExtForMode(mode) {
        if (mode === "CSV → JSON") return ".json"
        if (mode === "JSON → CSV") return ".csv"
        if (mode === "Markdown → HTML") return ".html"
        return ".out"
    }

    function inputFiltersForMode(mode) {
        if (mode === "CSV → JSON") return ["CSV (*.csv)", "Все файлы (*)"]
        if (mode === "JSON → CSV") return ["JSON (*.json)", "Все файлы (*)"]
        if (mode === "Markdown → HTML") return ["Markdown (*.md *.markdown)", "Все файлы (*)"]
        return ["Все файлы (*)"]
    }

    FileDialog {
        id: openDialog
        title: "Выбери исходный файл"
        nameFilters: page.inputFiltersForMode(page.modes[page.modeIdx])
        onAccepted: {
            page.inputPath = converter.toLocalPath(selectedFile)
            page.outputPath = converter.suggestOutputPath(
                page.inputPath, page.targetExtForMode(page.modes[page.modeIdx]))
        }
    }
    FileDialog {
        id: saveDialog
        title: "Сохранить как"
        fileMode: FileDialog.SaveFile
        onAccepted: page.outputPath = converter.toLocalPath(selectedFile)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 18

        ColumnLayout {
            spacing: 4
            Text {
                text: "Данные"
                color: theme.textPrimary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 24
                font.weight: Font.Bold
            }
            Text {
                text: "CSV ↔ JSON и Markdown → HTML"
                color: theme.textSecondary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 13
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
                        text: "Режим"
                        color: theme.textSecondary
                        font.family: "Inter, Segoe UI, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                    SegmentedSelector {
                        Layout.fillWidth: true
                        model: page.modes
                        currentIndex: page.modeIdx
                        onActivated: function(index, value) {
                            page.modeIdx = index
                            if (page.inputPath) {
                                page.outputPath = converter.suggestOutputPath(
                                    page.inputPath, page.targetExtForMode(value))
                            }
                        }
                    }
                }
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
                hint: "Перетащи файл сюда или нажми, чтобы выбрать"
                onOpenRequested: openDialog.open()
                onCleared: { page.inputPath = ""; page.outputPath = "" }
                onFilePathChanged: {
                    if (filePath !== page.inputPath) {
                        page.inputPath = filePath
                        page.outputPath = converter.suggestOutputPath(
                            page.inputPath, page.targetExtForMode(page.modes[page.modeIdx]))
                    }
                }
            }
        }

        AcrylicCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 80

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 6

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
                enabled: page.inputPath !== "" && page.outputPath !== "" && page.modes.length > 0
                onClicked: {
                    const ok = converter.convertData(
                        page.inputPath, page.outputPath, page.modes[page.modeIdx])
                    page.lastSuccess = ok
                    page.lastResultText = converter.lastMessage
                }
            }
        }
    }
}

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
    property var modes: converter ? converter.videoModes() : []
    property int modeIdx: 0
    property int durationSec: 4
    property int fps: 15
    property int maxWidth: 0       // 0 == keep
    property string lastResultText: ""
    property bool lastSuccess: true
    property bool ffmpegReady: converter ? converter.ffmpegAvailable() : false

    function currentMode() { return modes.length ? modes[modeIdx] : "" }
    function isImageInput() {
        const m = currentMode()
        return m.startsWith("Изображение")
    }
    function isVideoOrGifToImage() {
        const m = currentMode()
        return m.indexOf("→ Изображение") !== -1
    }
    function isToGif()   { return currentMode().endsWith("GIF") }
    function isToMp4()   { return currentMode().indexOf("MP4") !== -1 }
    function defaultExt() {
        if (isToGif())                 return ".gif"
        if (isToMp4())                 return ".mp4"
        if (isVideoOrGifToImage())     return ".png"
        return ".bin"
    }

    function refreshOutputExt() {
        if (!page.inputPath) return
        page.outputPath = converter.suggestOutputPath(page.inputPath, defaultExt())
    }

    FileDialog {
        id: openDialog
        title: "Выбери файл-источник"
        nameFilters: page.isImageInput()
            ? ["Изображения (*.png *.jpg *.jpeg *.bmp *.webp *.tiff *.gif)", "Все файлы (*)"]
            : currentMode().startsWith("GIF")
                ? ["GIF (*.gif)", "Все файлы (*)"]
                : ["Видео (*.mp4 *.mov *.mkv *.avi *.webm *.m4v *.gif)", "Все файлы (*)"]
        onAccepted: {
            page.inputPath = converter.toLocalPath(selectedFile)
            page.refreshOutputExt()
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
                text: "Видео и GIF"
                color: theme.textPrimary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 24
                font.weight: Font.Bold
            }
            Text {
                text: "Изображение ↔ MP4 ↔ GIF. Внутри — ffmpeg."
                color: theme.textSecondary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 13
            }
        }

        // ----------- ffmpeg-not-found banner -----------
        Rectangle {
            visible: !page.ffmpegReady
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: 10
            color: Qt.rgba(0.95, 0.45, 0.20, 0.12)
            border.width: 1
            border.color: Qt.rgba(0.95, 0.45, 0.20, 0.45)
            Text {
                anchors.fill: parent
                anchors.margins: 12
                verticalAlignment: Text.AlignVCenter
                text: "ffmpeg не найден. Положи ffmpeg.exe рядом с программой или установи в PATH."
                color: theme.textPrimary
                font.family: "Inter, Segoe UI, sans-serif"
                font.pixelSize: 12
            }
        }

        // ----------- mode -----------
        AcrylicCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 92

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 8
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
                        page.refreshOutputExt()
                    }
                }
            }
        }

        // ----------- source file -----------
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

        // ----------- parameters -----------
        AcrylicCard {
            Layout.fillWidth: true
            Layout.preferredHeight: paramsCol.implicitHeight + 36

            ColumnLayout {
                id: paramsCol
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                // Duration (only useful for image → video / image → gif)
                ColumnLayout {
                    spacing: 6
                    visible: page.isImageInput() && (page.isToMp4() || page.isToGif())
                    Layout.fillWidth: true
                    Text {
                        text: "Длительность ролика"
                        color: theme.textSecondary
                        font.family: "Inter, Segoe UI, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                    RowLayout {
                        spacing: 12
                        Layout.fillWidth: true
                        Slider {
                            id: durSlider
                            Layout.fillWidth: true
                            from: 1; to: 30
                            stepSize: 1
                            value: page.durationSec
                            onMoved: page.durationSec = Math.round(value)
                            background: Rectangle {
                                x: durSlider.leftPadding
                                y: durSlider.topPadding + durSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200; implicitHeight: 6
                                width: durSlider.availableWidth; height: implicitHeight
                                radius: 3
                                color: theme.divider
                                Rectangle {
                                    width: durSlider.visualPosition * parent.width
                                    height: parent.height; radius: 3
                                    color: theme.accent
                                }
                            }
                            handle: Rectangle {
                                x: durSlider.leftPadding + durSlider.visualPosition * (durSlider.availableWidth - width)
                                y: durSlider.topPadding + durSlider.availableHeight / 2 - height / 2
                                implicitWidth: 18; implicitHeight: 18; radius: 9
                                color: durSlider.pressed ? theme.accentHover : theme.accent
                                border.width: 2; border.color: theme.bg
                            }
                        }
                        Text {
                            text: page.durationSec + " с"
                            color: theme.accent
                            font.family: "Inter, Segoe UI, sans-serif"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            Layout.preferredWidth: 50
                        }
                    }
                }

                // FPS for video → gif and gif → video
                ColumnLayout {
                    spacing: 6
                    visible: page.currentMode() === "Видео → GIF" || page.currentMode() === "GIF → Видео (MP4)"
                    Layout.fillWidth: true
                    Text {
                        text: "Частота кадров (FPS)"
                        color: theme.textSecondary
                        font.family: "Inter, Segoe UI, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                    RowLayout {
                        spacing: 12
                        Layout.fillWidth: true
                        Slider {
                            id: fpsSlider
                            Layout.fillWidth: true
                            from: 5; to: 30
                            stepSize: 1
                            value: page.fps
                            onMoved: page.fps = Math.round(value)
                            background: Rectangle {
                                x: fpsSlider.leftPadding
                                y: fpsSlider.topPadding + fpsSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200; implicitHeight: 6
                                width: fpsSlider.availableWidth; height: implicitHeight
                                radius: 3; color: theme.divider
                                Rectangle {
                                    width: fpsSlider.visualPosition * parent.width
                                    height: parent.height; radius: 3
                                    color: theme.accent
                                }
                            }
                            handle: Rectangle {
                                x: fpsSlider.leftPadding + fpsSlider.visualPosition * (fpsSlider.availableWidth - width)
                                y: fpsSlider.topPadding + fpsSlider.availableHeight / 2 - height / 2
                                implicitWidth: 18; implicitHeight: 18; radius: 9
                                color: fpsSlider.pressed ? theme.accentHover : theme.accent
                                border.width: 2; border.color: theme.bg
                            }
                        }
                        Text {
                            text: page.fps + " fps"
                            color: theme.accent
                            font.family: "Inter, Segoe UI, sans-serif"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            Layout.preferredWidth: 60
                        }
                    }
                }

                // Max width (used by all modes; 0 keeps original)
                ColumnLayout {
                    spacing: 6
                    Layout.fillWidth: true
                    Text {
                        text: "Макс. ширина (0 — без изменения)"
                        color: theme.textSecondary
                        font.family: "Inter, Segoe UI, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                    RowLayout {
                        spacing: 12
                        Layout.fillWidth: true
                        Slider {
                            id: wSlider
                            Layout.fillWidth: true
                            from: 0; to: 1920
                            stepSize: 80
                            value: page.maxWidth
                            onMoved: page.maxWidth = Math.round(value)
                            background: Rectangle {
                                x: wSlider.leftPadding
                                y: wSlider.topPadding + wSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200; implicitHeight: 6
                                width: wSlider.availableWidth; height: implicitHeight
                                radius: 3; color: theme.divider
                                Rectangle {
                                    width: wSlider.visualPosition * parent.width
                                    height: parent.height; radius: 3
                                    color: theme.accent
                                }
                            }
                            handle: Rectangle {
                                x: wSlider.leftPadding + wSlider.visualPosition * (wSlider.availableWidth - width)
                                y: wSlider.topPadding + wSlider.availableHeight / 2 - height / 2
                                implicitWidth: 18; implicitHeight: 18; radius: 9
                                color: wSlider.pressed ? theme.accentHover : theme.accent
                                border.width: 2; border.color: theme.bg
                            }
                        }
                        Text {
                            text: page.maxWidth === 0 ? "—" : (page.maxWidth + " px")
                            color: theme.accent
                            font.family: "Inter, Segoe UI, sans-serif"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            Layout.preferredWidth: 80
                        }
                    }
                }

                // Output path
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
                text: converter && converter.busy ? "Конвертирую…" : "Конвертировать"
                enabled: page.ffmpegReady
                         && page.inputPath !== ""
                         && page.outputPath !== ""
                         && !(converter && converter.busy)
                onClicked: {
                    const ok = converter.convertVideo(
                        page.inputPath, page.outputPath, page.currentMode(),
                        page.durationSec, page.fps, page.maxWidth)
                    page.lastSuccess = ok
                    page.lastResultText = converter.lastMessage
                }
            }
        }
    }
}

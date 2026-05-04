import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

// Volchay con Pro logo:
//   [ image-file ]  ⇄  [ video-file ]
//
// Designed with filled shapes only (no thin strokes) so the icon stays
// crisp at the title-bar size, and a much larger inner detail area so the
// "image" / "video" semantics are immediately recognisable.
Item {
    id: root
    implicitWidth: 96
    implicitHeight: 56

    property color paper:      theme ? theme.surface     : Qt.rgba(1,1,1,0.05)
    property color paperRim:   theme ? theme.textPrimary : "#F2F1ED"
    property color glyph:      theme ? theme.textPrimary : "#F2F1ED"
    property color arrowColor: theme ? theme.accent      : "#F59E0B"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ---------- Left: image-file ----------
        Item {
            id: imageFile
            Layout.preferredWidth: root.height * 0.66
            Layout.preferredHeight: root.height * 0.92
            Layout.alignment: Qt.AlignVCenter

            // Filled paper with a folded top-right corner (cut as a triangle).
            Shape {
                id: imagePaper
                anchors.fill: parent
                ShapePath {
                    strokeColor: root.paperRim
                    strokeWidth: Math.max(1.0, root.height * 0.045)
                    fillColor: root.paper
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin
                    startX: 1; startY: 1
                    PathLine { x: imagePaper.width * 0.74; y: 1 }
                    PathLine { x: imagePaper.width - 1;    y: imagePaper.height * 0.26 }
                    PathLine { x: imagePaper.width - 1;    y: imagePaper.height - 1 }
                    PathLine { x: 1;                       y: imagePaper.height - 1 }
                    PathLine { x: 1;                       y: 1 }
                }
                // Fold-line indicator (the corner triangle outline)
                ShapePath {
                    strokeColor: root.paperRim
                    strokeWidth: Math.max(1.0, root.height * 0.035)
                    fillColor: "transparent"
                    startX: imagePaper.width * 0.74; startY: 1
                    PathLine { x: imagePaper.width * 0.74; y: imagePaper.height * 0.26 }
                    PathLine { x: imagePaper.width - 1;    y: imagePaper.height * 0.26 }
                }
            }

            // Inner image area: filled mountain (big triangle in glyph) + sun
            Item {
                id: imgInner
                x: parent.width * 0.16
                y: parent.height * 0.40
                width: parent.width * 0.68
                height: parent.height * 0.50

                // Sun (filled accent disc)
                Rectangle {
                    width: imgInner.width * 0.34
                    height: width
                    radius: width / 2
                    color: root.arrowColor
                    x: imgInner.width * 0.06
                    y: imgInner.height * 0.06
                }
                // Mountain (filled glyph triangle, fills lower portion)
                Shape {
                    id: mountain
                    anchors.fill: parent
                    ShapePath {
                        strokeColor: "transparent"
                        fillColor: root.glyph
                        startX: 0;                              startY: mountain.height
                        PathLine { x: mountain.width * 0.46;    y: mountain.height * 0.20 }
                        PathLine { x: mountain.width * 0.78;    y: mountain.height * 0.55 }
                        PathLine { x: mountain.width;           y: mountain.height * 0.30 }
                        PathLine { x: mountain.width;           y: mountain.height }
                        PathLine { x: 0;                        y: mountain.height }
                    }
                }
            }
        }

        // ---------- Middle: swap arrows (always centered) ----------
        Item {
            id: arrowSlot
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: root.height * 0.45

            Shape {
                id: arrows
                anchors.centerIn: parent
                width: Math.min(parent.width - root.height * 0.10, root.height * 0.95)
                height: root.height * 0.62
                antialiasing: true
                layer.enabled: true
                layer.samples: 8

                // Top-right arrow (filled triangular head + thick shaft)
                ShapePath {
                    strokeColor: "transparent"
                    fillColor: root.arrowColor
                    fillRule: ShapePath.WindingFill
                    startX: arrows.width * 0.05; startY: arrows.height * 0.22
                    PathLine { x: arrows.width * 0.62; y: arrows.height * 0.22 }
                    PathLine { x: arrows.width * 0.62; y: arrows.height * 0.06 }
                    PathLine { x: arrows.width * 0.97; y: arrows.height * 0.32 }
                    PathLine { x: arrows.width * 0.62; y: arrows.height * 0.58 }
                    PathLine { x: arrows.width * 0.62; y: arrows.height * 0.42 }
                    PathLine { x: arrows.width * 0.05; y: arrows.height * 0.42 }
                    PathLine { x: arrows.width * 0.05; y: arrows.height * 0.22 }
                }
                // Bottom-left arrow
                ShapePath {
                    strokeColor: "transparent"
                    fillColor: root.arrowColor
                    fillRule: ShapePath.WindingFill
                    startX: arrows.width * 0.95; startY: arrows.height * 0.78
                    PathLine { x: arrows.width * 0.38; y: arrows.height * 0.78 }
                    PathLine { x: arrows.width * 0.38; y: arrows.height * 0.94 }
                    PathLine { x: arrows.width * 0.03; y: arrows.height * 0.68 }
                    PathLine { x: arrows.width * 0.38; y: arrows.height * 0.42 }
                    PathLine { x: arrows.width * 0.38; y: arrows.height * 0.58 }
                    PathLine { x: arrows.width * 0.95; y: arrows.height * 0.58 }
                    PathLine { x: arrows.width * 0.95; y: arrows.height * 0.78 }
                }
            }
        }

        // ---------- Right: video-file ----------
        Item {
            id: videoFile
            Layout.preferredWidth: root.height * 0.66
            Layout.preferredHeight: root.height * 0.92
            Layout.alignment: Qt.AlignVCenter

            Shape {
                id: videoPaper
                anchors.fill: parent
                ShapePath {
                    strokeColor: root.paperRim
                    strokeWidth: Math.max(1.0, root.height * 0.045)
                    fillColor: root.paper
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin
                    startX: 1; startY: 1
                    PathLine { x: videoPaper.width * 0.74; y: 1 }
                    PathLine { x: videoPaper.width - 1;    y: videoPaper.height * 0.26 }
                    PathLine { x: videoPaper.width - 1;    y: videoPaper.height - 1 }
                    PathLine { x: 1;                       y: videoPaper.height - 1 }
                    PathLine { x: 1;                       y: 1 }
                }
                ShapePath {
                    strokeColor: root.paperRim
                    strokeWidth: Math.max(1.0, root.height * 0.035)
                    fillColor: "transparent"
                    startX: videoPaper.width * 0.74; startY: 1
                    PathLine { x: videoPaper.width * 0.74; y: videoPaper.height * 0.26 }
                    PathLine { x: videoPaper.width - 1;    y: videoPaper.height * 0.26 }
                }
            }

            // Big play triangle, filled in accent
            Shape {
                id: playTri
                x: parent.width * 0.20
                y: parent.height * 0.34
                width: parent.width * 0.56
                height: parent.height * 0.56
                ShapePath {
                    strokeColor: "transparent"
                    fillColor: root.arrowColor
                    fillRule: ShapePath.WindingFill
                    startX: 1;                       startY: 1
                    PathLine { x: playTri.width;     y: playTri.height * 0.50 }
                    PathLine { x: 1;                 y: playTri.height - 1 }
                    PathLine { x: 1;                 y: 1 }
                }
            }
        }
    }
}

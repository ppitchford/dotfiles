import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: volumePanel

    required property QtObject theme
    required property bool     visible_

    visible:       visible_
    anchors.bottom:   true
    anchors.right: true
    implicitWidth:  260
    implicitHeight: col.implicitHeight + 24
    color: "transparent"

    // ── Processes ─────────────────────────────────────────────────────────────

    Process {
        id: volumeProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: visible_
        property real volume: 0.6
        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/Volume:\s+([\d.]+)/)
                if (match) volumeProcess.volume = parseFloat(match[1])
            }
        }
    }

    Process {
        id: volumeSetter
        property string level: "0.60"
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", level]
    }

    Process {
        id: micProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        running: visible_
        property real volume: 1.0
        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/Volume:\s+([\d.]+)/)
                if (match) micProcess.volume = parseFloat(match[1])
            }
        }
    }

    Process {
        id: micSetter
        property string level: "1.00"
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", level]
    }

    Timer {
        interval: 2000
        running:  visible_
        repeat:   true
        onTriggered: {
            volumeProcess.running = true
            micProcess.running    = true
        }
    }

    // ── UI ────────────────────────────────────────────────────────────────────

    Rectangle {
        anchors.fill:  parent
        color:         theme.cBg1
        radius:        8
        border.width:  1
        border.color:  theme.cBorder

        ColumnLayout {
            id: col
            anchors.fill:    parent
            anchors.margins: 12
            spacing:         10

            Text {
                text:           "Volume"
                color:          theme.cFg
                font.family:    "Inter"
                font.pixelSize: 13
                font.bold:      true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: theme.cBg2 }

            // Speaker
            Text { text: "\uf028     Speaker"; color: theme.cMuted; font.family: "Inter"; font.pixelSize: 12; font.bold: true }

            RowLayout {
                Layout.fillWidth: true; spacing: 8

                Rectangle {
                    Layout.fillWidth: true; height: 6; radius: 3; color: theme.cBg2

                    Rectangle { width: volumeProcess.volume * parent.width; height: parent.height; radius: 3; color: theme.cGreen }

                    Rectangle {
                        id: speakerHandle
                        x: volumeProcess.volume * (parent.width - width)
                        y: (parent.height - height) / 2
                        width: 14; height: 14; radius: 7; color: theme.cFg
                    }

                    MouseArea {
                        anchors.fill: parent
                        drag.target: speakerHandle; drag.axis: Drag.XAxis
                        drag.minimumX: 0; drag.maximumX: parent.width - speakerHandle.width
                        onPressed:         mouse => setVol(mouse.x, parent.width)
                        onPositionChanged: mouse => { if (pressed) setVol(mouse.x, parent.width) }
                        function setVol(x, w) {
                            const v = Math.max(0, Math.min(1, x / w))
                            volumeProcess.volume = v; volumeSetter.level = v.toFixed(2); volumeSetter.running = true
                        }
                    }
                }

                Text { text: Math.round(volumeProcess.volume * 100) + "%"; color: theme.cFg; font.family: "Inter"; font.pixelSize: 12; font.bold: true; Layout.minimumWidth: 36 }
            }

            // Microphone
            Text { text: "\uf130    Microphone"; color: theme.cMuted; font.family: "Inter"; font.pixelSize: 12; font.bold: true }

            RowLayout {
                Layout.fillWidth: true; spacing: 8

                Rectangle {
                    Layout.fillWidth: true; height: 6; radius: 3; color: theme.cBg2

                    Rectangle { width: micProcess.volume * parent.width; height: parent.height; radius: 3; color: theme.cOrange }

                    Rectangle {
                        id: micHandle
                        x: micProcess.volume * (parent.width - width)
                        y: (parent.height - height) / 2
                        width: 14; height: 14; radius: 7; color: theme.cFg
                    }

                    MouseArea {
                        anchors.fill: parent
                        drag.target: micHandle; drag.axis: Drag.XAxis
                        drag.minimumX: 0; drag.maximumX: parent.width - micHandle.width
                        onPressed:         mouse => setMic(mouse.x, parent.width)
                        onPositionChanged: mouse => { if (pressed) setMic(mouse.x, parent.width) }
                        function setMic(x, w) {
                            const v = Math.max(0, Math.min(1, x / w))
                            micProcess.volume = v; micSetter.level = v.toFixed(2); micSetter.running = true
                        }
                    }
                }

                Text { text: Math.round(micProcess.volume * 100) + "%"; color: theme.cFg; font.family: "Inter"; font.pixelSize: 12; font.bold: true; Layout.minimumWidth: 36 }
            }
        }
    }
}

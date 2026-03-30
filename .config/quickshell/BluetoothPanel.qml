import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: btPanel

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
        id: btDevicesProcess
        command: ["bluetoothctl", "devices", "Paired"]
        running: visible_
        property var devices: []
        property var results: []

        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/Device\s+([0-9A-F:]+)\s+(.+)/)
                if (match) btDevicesProcess.results.push({ address: match[1], name: match[2].trim() })
            }
        }

        onRunningChanged: {
            if (!running) { devices = results; results = [] }
            else          { results = [] }
        }
    }

    Process {
        id: btConnectProcess
        property string address: ""
        command: ["bluetoothctl", "connect", address]
    }

    Process {
        id: btDisconnectProcess
        property string address: ""
        command: ["bluetoothctl", "disconnect", address]
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
            spacing:         6

            Text {
                text:           "Bluetooth"
                color:          theme.cFg
                font.family:    "Inter"
                font.pixelSize: 13
                font.bold:      true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: theme.cBg2 }

            Repeater {
                model: btDevicesProcess.devices
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 34; radius: 6
                    color: btItem.containsMouse ? theme.cBg2 : "transparent"

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 8; spacing: 8
                        Text { text: "\uf293"; color: theme.cAccent; font.family: "Inter"; font.pixelSize: 13 }
                        Text { text: modelData.name; color: theme.cFg; font.family: "Inter"; font.pixelSize: 13; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
                        Text { text: "\uf00c"; color: theme.cGreen; font.family: "Inter"; font.pixelSize: 12
                            MouseArea { anchors.fill: parent; onClicked: { btConnectProcess.address = modelData.address; btConnectProcess.running = true } } }
                        Text { text: "\uf00d"; color: theme.cRed; font.family: "Inter"; font.pixelSize: 12
                            MouseArea { anchors.fill: parent; onClicked: { btDisconnectProcess.address = modelData.address; btDisconnectProcess.running = true } } }
                    }

                    MouseArea { id: btItem; anchors.fill: parent; hoverEnabled: true }
                }
            }

            Text {
                visible: btDevicesProcess.devices.length === 0
                text:    "No paired devices"
                color:   theme.cMuted
                font.family:    "Inter"
                font.pixelSize: 13
                font.bold:      true
                width:   parent.width
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}

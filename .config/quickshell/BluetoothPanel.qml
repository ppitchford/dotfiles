import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: btPanel

    required property QtObject theme
    required property bool     visible_

    visible:        visible_
    anchors.top:    true
    anchors.right:  true
    implicitWidth:  260
    implicitHeight: col.implicitHeight + 24
    color: "transparent"

    property var connectedAddrs: []

    // ── Processes ─────────────────────────────────────────────────────────────

    Process {
        id: btPairedProcess
        command: ["bluetoothctl", "devices", "Paired"]
        property var devices: []
        property var results: []

        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/Device\s+([0-9A-F:]+)\s+(.+)/)
                if (match) btPairedProcess.results.push({ address: match[1], name: match[2].trim() })
            }
        }

        onRunningChanged: {
            if (!running) { devices = results; results = [] }
            else          { results = [] }
        }
    }

    Process {
        id: btConnectedProcess
        command: ["bluetoothctl", "devices", "Connected"]
        property var results: []

        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/Device\s+([0-9A-F:]+)\s+/)
                if (match) btConnectedProcess.results.push(match[1])
            }
        }

        onRunningChanged: {
            if (!running) { connectedAddrs = results; results = [] }
            else          { results = [] }
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: btConnectedProcess.running = true
    }

    Process {
        id: btConnectProcess
        property string address: ""
        command: ["bluetoothctl", "connect", address]
        onRunningChanged: { if (!running) btConnectedProcess.running = true }
    }

    Process {
        id: btDisconnectProcess
        property string address: ""
        command: ["bluetoothctl", "disconnect", address]
        onRunningChanged: { if (!running) btConnectedProcess.running = true }
    }

    function isConnected(address)  { return connectedAddrs.indexOf(address) !== -1 }
    function connectedDevices()    { return btPairedProcess.devices.filter(d => isConnected(d.address)) }
    function otherDevices()        { return btPairedProcess.devices.filter(d => !isConnected(d.address)) }

    onVisible_Changed: {
        if (visible_) {
            btPairedProcess.running    = true
            btConnectedProcess.running = true
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
            spacing:         6

            Text {
                text:           "Bluetooth"
                color:          theme.cFg
                font.family:    "Atkinson Hyperlegible"
                font.pixelSize: 13
                font.bold:      true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: theme.cBg2 }

            // Connected devices — pinned at top
            Repeater {
                model: connectedDevices()
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 34; radius: 6; color: theme.cBg2

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 8; spacing: 8

                        Text { text: "\uf293"; color: theme.cAccent; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 13 }
                        Text {
                            text: modelData.name; color: theme.cFg
                            font.family: "Atkinson Hyperlegible"; font.pixelSize: 13; font.bold: true
                            Layout.fillWidth: true; elide: Text.ElideRight
                        }

                        Rectangle {
                            implicitWidth: 24; implicitHeight: 24; radius: 4
                            color: disconnectArea.containsMouse ? theme.cRed : "transparent"
                            Text {
                                anchors.centerIn: parent; text: "\uf00d"
                                color: disconnectArea.containsMouse ? theme.cBg : theme.cMuted
                                font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 12
                            }
                            MouseArea {
                                id: disconnectArea
                                anchors.fill: parent; hoverEnabled: true
                                onClicked: {
                                    btDisconnectProcess.address = modelData.address
                                    btDisconnectProcess.running = true
                                }
                            }
                        }
                    }
                }
            }

            // Paired but not connected
            Text {
                visible: otherDevices().length > 0
                text: "Paired"; color: theme.cMuted
                font.family: "Atkinson Hyperlegible"; font.pixelSize: 10; font.bold: true
                leftPadding: 4; topPadding: 2
            }

            Repeater {
                model: otherDevices()
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 34; radius: 6
                    color: rowArea.containsMouse ? theme.cBg2 : theme.cBg1

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 8; spacing: 8
                        Text { text: "\uf293"; color: theme.cMuted; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 13 }
                        Text {
                            text: modelData.name; color: theme.cFg
                            font.family: "Atkinson Hyperlegible"; font.pixelSize: 13
                            Layout.fillWidth: true; elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: rowArea
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            btConnectProcess.address = modelData.address
                            btConnectProcess.running = true
                        }
                    }
                }
            }

            Text {
                visible: btPairedProcess.devices.length === 0
                text:    "No paired devices"
                color:   theme.cMuted
                font.family: "Atkinson Hyperlegible"; font.pixelSize: 13; font.bold: true
                width:   parent.width
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}

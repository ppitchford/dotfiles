import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: networkPanel

    required property QtObject theme
    required property bool     visible_

    visible:       visible_
    anchors.bottom:   true
    anchors.right: true
    implicitWidth:  260
    implicitHeight: col.implicitHeight + 24
    color: "transparent"

    property string activeNetwork: ""
    property string activeSignal:  ""
    property string connectingTo:  ""
    property string passwordInput: ""

    // ── Processes ─────────────────────────────────────────────────────────────

    Process {
        id: networkStatusProcess
        command: ["iwctl", "station", "wlp192s0", "show"]
        property var lines: []

        stdout: SplitParser { onRead: data => networkStatusProcess.lines.push(data) }

        onRunningChanged: {
            if (!running) {
                let ssid = "", signal = ""
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i]
                    if (line.match(/Connected network/)) {
                        const parts = line.trim().split(/\s{2,}/)
                        if (parts.length >= 2) ssid = parts[parts.length - 1].trim()
                    }
                    if (line.match(/RSSI/)) {
                        const parts = line.trim().split(/\s{2,}/)
                        if (parts.length >= 2) signal = parts[parts.length - 1].trim()
                    }
                }
                activeNetwork = ssid
                activeSignal  = signal
                lines = []
            } else { lines = [] }
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: networkStatusProcess.running = true
    }

    Process {
        id: networkScanProcess
        command: ["iwctl", "station", "wlp192s0", "get-networks"]
        property var  networks: []
        property var  results:  []
        property bool scanning: false

        stdout: SplitParser {
            onRead: data => {
                const line = data.replace(/\x1b\[[0-9;]*m/g, "").trim()
                if (!line || line.startsWith("Available") || line.startsWith("Network") || line.startsWith("-")) return
                const active = line.startsWith(">")
                const clean  = line.replace(/^>\s*/, "").trim()
                const parts  = clean.split(/\s{2,}/)
                if (parts[0] && parts[0].trim()) networkScanProcess.results.push({
                    ssid:     parts[0].trim(),
                    security: parts[1] ? parts[1].trim() : "",
                    signal:   parts[2] ? parts[2].trim() : "",
                    active:   active
                })
            }
        }

        onRunningChanged: {
            if (running) { scanning = true; results = [] }
            else { scanning = false; if (results.length > 0) { networks = results; results = [] } }
        }
    }

    Process {
        id: savedNetworksProcess
        command: ["iwctl", "known-networks", "list"]
        property var saved:   []
        property var results: []

        stdout: SplitParser {
            onRead: data => {
                const line = data.replace(/\x1b\[[0-9;]*m/g, "").trim()
                if (!line || line.startsWith("Known") || line.startsWith("-") || line.startsWith("Name")) return
                const parts = line.split(/\s{2,}/)
                if (parts[0] && parts[0].trim()) savedNetworksProcess.results.push(parts[0].trim())
            }
        }

        onRunningChanged: {
            if (!running) { saved = results; results = [] }
            else          { results = [] }
        }
    }

    Process {
        id: networkConnectProcess
        property string ssid:     ""
        property string password: ""
        command: password !== ""
            ? ["iwctl", "--passphrase=" + password, "station", "wlp192s0", "connect", ssid]
            : ["iwctl", "station", "wlp192s0", "connect", ssid]
        onRunningChanged: { if (!running) networkStatusProcess.running = true }
    }

    Process {
        id: networkDisconnectProcess
        command: ["iwctl", "station", "wlp192s0", "disconnect"]
        onRunningChanged: { if (!running) networkStatusProcess.running = true }
    }

    function isSaved(ssid)  { return savedNetworksProcess.saved.indexOf(ssid) !== -1 }
    function savedNets()    { return networkScanProcess.networks.filter(n => isSaved(n.ssid)) }
    function otherNets()    { return networkScanProcess.networks.filter(n => !isSaved(n.ssid)) }

    onVisible_Changed: {
        if (visible_) {
            savedNetworksProcess.running = true
            networkScanProcess.running   = true
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
                text:           "Network"
                color:          theme.cFg
                font.family:    "Inter"
                font.pixelSize: 13
                font.bold:      true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: theme.cBg2 }

            // Connected state
            Rectangle {
                visible: activeNetwork !== ""
                Layout.fillWidth: true; height: 34; radius: 6; color: theme.cBg2

                RowLayout {
                    anchors.fill: parent; anchors.margins: 8; spacing: 8
                    Text { text: "\uf1eb"; color: theme.cAccent; font.family: "Inter"; font.pixelSize: 13 }
                    Text { text: activeNetwork + (activeSignal !== "" ? "  " + activeSignal : ""); color: theme.cFg; font.family: "Inter"; font.pixelSize: 13; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
                    Rectangle {
                        implicitWidth: 24; implicitHeight: 24; radius: 4
                        color: disconnectArea.containsMouse ? theme.cRed : "transparent"
                        Text { anchors.centerIn: parent; text: "\uf00d"; color: disconnectArea.containsMouse ? theme.cBg : theme.cMuted; font.family: "Inter"; font.pixelSize: 12 }
                        MouseArea { id: disconnectArea; anchors.fill: parent; hoverEnabled: true; onClicked: networkDisconnectProcess.running = true }
                    }
                }
            }

            // Scan button
            Rectangle {
                Layout.fillWidth: true; height: 30; radius: 6
                color: scanArea.containsMouse ? theme.cBg2 : "transparent"

                RowLayout {
                    anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: networkScanProcess.scanning ? "\uf110" : "\uf021"; color: theme.cMuted; font.family: "Inter"; font.pixelSize: 11 }
                    Text { text: networkScanProcess.scanning ? "Scanning..." : "Scan for networks"; color: theme.cMuted; font.family: "Inter"; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                }

                MouseArea {
                    id: scanArea; anchors.fill: parent; hoverEnabled: true
                    onClicked: { savedNetworksProcess.running = true; networkScanProcess.running = true }
                }
            }

            // Saved networks
            Text { visible: savedNets().length > 0; text: "Saved"; color: theme.cMuted; font.family: "Inter"; font.pixelSize: 10; font.bold: true; leftPadding: 4; topPadding: 2 }

            Repeater {
                model: savedNets()
                delegate: NetworkRow { theme: theme; modelData: modelData; connectProcess: networkConnectProcess }
            }

            // Other networks
            Text { visible: otherNets().length > 0; text: "Other"; color: theme.cMuted; font.family: "Inter"; font.pixelSize: 10; font.bold: true; leftPadding: 4; topPadding: 2 }

            Repeater {
                model: otherNets()
                delegate: NetworkRow { theme: theme; modelData: modelData; connectProcess: networkConnectProcess }
            }

            Text {
                visible: networkScanProcess.networks.length === 0 && !networkScanProcess.scanning
                text:    "No networks found"
                color:   theme.cMuted
                font.family: "Inter"; font.pixelSize: 13; font.bold: true
                width:   parent.width; horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}

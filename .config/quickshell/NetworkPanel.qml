import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: networkPanel

    required property QtObject theme
    required property bool     visible_

    property string wifiDevice: "wlp192s0"

    visible:       visible_
    anchors.top:      true
    anchors.right: true
    implicitWidth:  260
    implicitHeight: col.implicitHeight + 24
    color: "transparent"

    // Layer-shell surfaces get no keyboard by default, which meant the password
    // field below could never receive a keystroke. Take the keyboard only while
    // a password field is actually open, so the panel doesn't swallow input.
    WlrLayershell.keyboardFocus: passwordFor !== ""
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    property string activeNetwork: ""
    property string activeSignal:  ""
    property string passwordFor:   ""   // ssid whose password row is open
    property string connectError:  ""

    readonly property bool scanning: networkScanTrigger.running
        || scanSettle.running
        || networkScanProcess.running

    // ── Processes ─────────────────────────────────────────────────────────────

    Process {
        id: networkStatusProcess
        command: ["iwctl", "station", networkPanel.wifiDevice, "show"]
        property var lines: []

        stdout: SplitParser { onRead: data => networkStatusProcess.lines.push(data) }

        onRunningChanged: {
            if (!running) {
                let ssid = "", signal = ""
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i].replace(/\x1b\[[0-9;]*m/g, "")
                    if (line.match(/Connected network/)) {
                        const parts = line.trim().split(/\s{2,}/)
                        if (parts.length >= 2) ssid = parts[parts.length - 1].trim()
                    }
                    if (line.match(/^\s*RSSI/)) {
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

    // `get-networks` only ever returns iwd's *cached* results, so without this
    // the panel showed whatever was in range the last time something else
    // scanned — often nothing, or networks from the last city.
    Process {
        id: networkScanTrigger
        command: ["iwctl", "station", networkPanel.wifiDevice, "scan"]
        // Errors here are expected when a scan is already running; the results
        // fetch below still gives us whatever iwd has.
        onRunningChanged: { if (!running) scanSettle.start() }
    }

    // iwd's scan is asynchronous — give it a moment before reading results.
    Timer {
        id: scanSettle
        interval: 2500
        onTriggered: networkScanProcess.running = true
    }

    Process {
        id: networkScanProcess
        command: ["iwctl", "station", networkPanel.wifiDevice, "get-networks"]
        property var networks: []
        property var results:  []

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
            if (running) results = []
            // Assign unconditionally: an empty result really does mean nothing
            // is in range, and pretending otherwise leaves a stale list up.
            else { networks = results; results = [] }
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
            ? ["iwctl", "--passphrase=" + password, "station", networkPanel.wifiDevice, "connect", ssid]
            : ["iwctl", "station", networkPanel.wifiDevice, "connect", ssid]

        // Without this a bad passphrase just did nothing visible.
        stderr: SplitParser {
            onRead: data => {
                const line = data.replace(/\x1b\[[0-9;]*m/g, "").trim()
                if (line) networkPanel.connectError = line
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) networkPanel.connectError = ""
            else if (networkPanel.connectError === "")
                networkPanel.connectError = "Could not connect to " + ssid
            savedNetworksProcess.running = true
            networkStatusProcess.running = true
        }
    }

    Process {
        id: networkDisconnectProcess
        command: ["iwctl", "station", networkPanel.wifiDevice, "disconnect"]
        onRunningChanged: { if (!running) networkStatusProcess.running = true }
    }

    function isSaved(ssid)  { return savedNetworksProcess.saved.indexOf(ssid) !== -1 }
    function savedNets()    { return networkScanProcess.networks.filter(n => isSaved(n.ssid)) }
    function otherNets()    { return networkScanProcess.networks.filter(n => !isSaved(n.ssid)) }

    function startScan() {
        savedNetworksProcess.running = true
        networkScanTrigger.running   = true
    }

    function connectTo(ssid, password) {
        connectError = ""
        passwordFor  = ""
        networkConnectProcess.ssid     = ssid
        networkConnectProcess.password = password
        networkConnectProcess.running  = true
    }

    onVisible_Changed: {
        if (visible_) startScan()
        else { passwordFor = ""; connectError = "" }
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
                font.family:    "Atkinson Hyperlegible"
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
                    Text { text: "\uf1eb"; color: theme.cAccent; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 13 }
                    Text { text: activeNetwork + (activeSignal !== "" ? "  " + activeSignal : ""); color: theme.cFg; font.family: "Atkinson Hyperlegible"; font.pixelSize: 13; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
                    Rectangle {
                        implicitWidth: 24; implicitHeight: 24; radius: 4
                        color: disconnectArea.containsMouse ? theme.cRed : "transparent"
                        Text { anchors.centerIn: parent; text: "\uf00d"; color: disconnectArea.containsMouse ? theme.cBg : theme.cMuted; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 12 }
                        MouseArea { id: disconnectArea; anchors.fill: parent; hoverEnabled: true; onClicked: networkDisconnectProcess.running = true }
                    }
                }
            }

            // Connection error
            Text {
                visible:          connectError !== ""
                text:             connectError
                color:            theme.cRed
                font.family:      "Atkinson Hyperlegible"
                font.pixelSize:   11
                font.bold:        true
                wrapMode:         Text.WordWrap
                Layout.fillWidth: true
                leftPadding:      4
            }

            // Scan button
            Rectangle {
                Layout.fillWidth: true; height: 30; radius: 6
                color: scanArea.containsMouse ? theme.cBg2 : "transparent"

                RowLayout {
                    anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: networkPanel.scanning ? "\uf110" : "\uf021"; color: theme.cMuted; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 11 }
                    Text { text: networkPanel.scanning ? "Scanning..." : "Scan for networks"; color: theme.cMuted; font.family: "Atkinson Hyperlegible"; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                }

                MouseArea {
                    id: scanArea; anchors.fill: parent; hoverEnabled: true
                    onClicked: networkPanel.startScan()
                }
            }

            // Saved networks
            Text { visible: savedNets().length > 0; text: "Saved"; color: theme.cMuted; font.family: "Atkinson Hyperlegible"; font.pixelSize: 10; font.bold: true; leftPadding: 4; topPadding: 2 }

            Repeater {
                // `theme: theme` here would bind the delegate's own property to
                // itself (null) — it has to be qualified. modelData is injected
                // by the Repeater, so it must not be assigned at all.
                model: savedNets()
                delegate: NetworkRow { theme: networkPanel.theme; panel: networkPanel; saved: true }
            }

            // Other networks
            Text { visible: otherNets().length > 0; text: "Other"; color: theme.cMuted; font.family: "Atkinson Hyperlegible"; font.pixelSize: 10; font.bold: true; leftPadding: 4; topPadding: 2 }

            Repeater {
                model: otherNets()
                delegate: NetworkRow { theme: networkPanel.theme; panel: networkPanel; saved: false }
            }

            Text {
                visible: networkScanProcess.networks.length === 0 && !networkPanel.scanning
                text:    "No networks found"
                color:   theme.cMuted
                font.family: "Atkinson Hyperlegible"; font.pixelSize: 13; font.bold: true
                width:   parent.width; horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}

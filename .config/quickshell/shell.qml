import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root

    // ── Theme ─────────────────────────────────────────────────────────────────

    FileView {
        id: themeFile
        path: "/home/philipp/.config/theme/current"
        watchChanges: true
        onFileChanged: reload()
    }

    QtObject {
        id: theme
        property bool isDark: themeFile.text().trim() !== "light"
        property color cBg:     isDark ? "#191724" : "#faf4ed"
        property color cBg1:    isDark ? "#1f1d2e" : "#fffaf3"
        property color cBg2:    isDark ? "#26233a" : "#f2e9e1"
        property color cFg:     isDark ? "#e0def4" : "#3d3c4a"
        property color cMuted:  isDark ? "#6e6a86" : "#9893a5"
        property color cAccent: isDark ? "#31748f" : "#286983"
        property color cGreen:  isDark ? "#9ccfd8" : "#56949f"
        property color cYellow: isDark ? "#f6c177" : "#ea9d34"
        property color cRed:    isDark ? "#eb6f92" : "#b4637a"
        property color cOrange: isDark ? "#ebbcba" : "#d7827e"
        property color cBorder: isDark ? "#403d52" : "#dfdad9"
    }

    // ── Clock ─────────────────────────────────────────────────────────────────

    property string clockText: Qt.formatTime(new Date(), "HH:mm")
    property string dateText:  Qt.formatDate(new Date(), "dddd, MMMM d yyyy")

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            clockText = Qt.formatTime(new Date(), "HH:mm")
            dateText  = Qt.formatDate(new Date(), "dddd, MMMM d yyyy")
        }
    }

    // ── Tags ──────────────────────────────────────────────────────────────────

    property int activeTag:    1
    property var occupiedTags: [1]

    Process {
        id: tagProcess
        command: ["mmsg", "-g", "-t"]
        property var lines: []

        stdout: SplitParser { onRead: data => tagProcess.lines.push(data.trim()) }

        onRunningChanged: {
            if (!running && lines.length > 0) {
                let newActive  = 1
                const occupied = []
                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(/\s+/)
                    if (parts.length === 6 && parts[1] === "tag") {
                        const tagNum  = parseInt(parts[2])
                        const state   = parseInt(parts[3])
                        const clients = parseInt(parts[4])
                        if (state === 1)  newActive = tagNum
                        if (clients > 0)  occupied.push(tagNum)
                    }
                }
                if (occupied.indexOf(newActive) === -1) occupied.push(newActive)
                occupied.sort((a, b) => a - b)
                activeTag    = newActive
                occupiedTags = occupied
                lines = []
            } else if (running) { lines = [] }
        }
    }

    Timer { interval: 500; running: true; repeat: true; onTriggered: tagProcess.running = true }

    // ── Battery ───────────────────────────────────────────────────────────────

    Process {
        id: batteryCapacity
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1"]
        running: true
        property int capacity: 100
        stdout: SplitParser { onRead: data => batteryCapacity.capacity = parseInt(data.trim()) || 100 }
    }

    Process {
        id: batteryStatus
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1"]
        running: true
        property string status: "Unknown"
        stdout: SplitParser { onRead: data => batteryStatus.status = data.trim() }
    }

    Timer { interval: 30000; running: true; repeat: true; onTriggered: { batteryCapacity.running = true; batteryStatus.running = true } }

    // ── Panel visibility state ────────────────────────────────────────────────

    property bool systemVisible:    false
    property bool bluetoothVisible: false
    property bool volumeVisible:    false
    property bool networkVisible:   false

    // Only one panel open at a time
    function openPanel(name) {
        systemVisible    = name === "system"
        bluetoothVisible = name === "bluetooth"
        volumeVisible    = name === "volume"
        networkVisible   = name === "network"
    }

    function closeAll() {
        systemVisible    = false
        bluetoothVisible = false
        volumeVisible    = false
        networkVisible   = false
    }

    // ── Bar ───────────────────────────────────────────────────────────────────

    Bar {
        id: bar
        theme:           theme
        activeTag:       root.activeTag
        occupiedTags:    root.occupiedTags
        clockText:       root.clockText
        dateText:        root.dateText
        batteryCapacity: batteryCapacity.capacity
        batteryStatus:   batteryStatus.status
        onToggleSystem:    root.systemVisible    ? root.closeAll() : root.openPanel("system")
        onToggleBluetooth: root.bluetoothVisible ? root.closeAll() : root.openPanel("bluetooth")
        onToggleVolume:    root.volumeVisible    ? root.closeAll() : root.openPanel("volume")
        onToggleNetwork:   root.networkVisible   ? root.closeAll() : root.openPanel("network")
    }

    // ── Panels ────────────────────────────────────────────────────────────────

    SystemPanel {
        theme:    theme
        visible_: root.systemVisible
    }

    BluetoothPanel {
        theme:    theme
        visible_: root.bluetoothVisible
    }

    VolumePanel {
        theme:    theme
        visible_: root.volumeVisible
    }

    NetworkPanel {
        theme:    theme
        visible_: root.networkVisible
    }

    // ── Calendar ──────────────────────────────────────────────────────────────

    Calendar {
        theme:    theme
        visible_: bar.clockHovered
    }
}

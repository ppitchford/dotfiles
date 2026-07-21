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
    //
    // The QML engine caches the local timezone when it starts, so `new Date()`
    // and Qt.formatTime() keep reporting the old zone after /etc/localtime is
    // changed — until quickshell is restarted. Instead we track the system UTC
    // offset ourselves (re-probed with `date`, which reads /etc/localtime on
    // every run) and build the wall clock from UTC, which never goes stale.

    property int    tzOffsetMin: 0    // minutes east of UTC
    property string tzName:      ""   // e.g. "PDT"

    // A Date whose *UTC* fields are the wall clock in the system timezone.
    property var    now:       new Date(0)
    property string clockText: ""
    property string dateText:  ""

    readonly property var dayNames: [
        "Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"
    ]
    readonly property var monthNames: [
        "January","February","March","April","May","June",
        "July","August","September","October","November","December"
    ]

    function pad2(n) { return n < 10 ? "0" + n : "" + n }

    function updateClock() {
        const d = new Date(Date.now() + tzOffsetMin * 60000)
        now       = d
        clockText = pad2(d.getUTCHours()) + ":" + pad2(d.getUTCMinutes())
        dateText  = dayNames[d.getUTCDay()] + ", " + monthNames[d.getUTCMonth()]
                  + " " + d.getUTCDate() + " " + d.getUTCFullYear()
    }

    // Wakes on the minute boundary rather than once a second. Minute boundaries
    // are the same in every timezone, so a stale cached zone can't skew them.
    SystemClock {
        precision: SystemClock.Minutes
        onDateChanged: root.updateClock()
    }

    Component.onCompleted: root.updateClock()

    // ── Timezone ──────────────────────────────────────────────────────────────

    Process {
        id: tzProbe
        command: ["date", "+%z %Z"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                const sign  = parts[0]                        // "-0700"
                if (!/^[+-]\d{4}$/.test(sign)) return
                const offset = (sign[0] === "-" ? -1 : 1)
                    * (parseInt(sign.substr(1, 2), 10) * 60 + parseInt(sign.substr(3, 2), 10))
                root.tzName = parts.length > 1 ? parts[1] : ""
                if (offset !== root.tzOffsetMin) {
                    root.tzOffsetMin = offset
                    root.updateClock()
                }
            }
        }
    }

    // Picks up timezone changes and DST transitions without a restart.
    Timer { interval: 15000; running: true; repeat: true; onTriggered: tzProbe.running = true }

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
        activeTag:       root.activeTag
        occupiedTags:    root.occupiedTags
        clockText:       root.clockText
        dateText:        root.dateText
        tzName:          root.tzName
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
        now:      root.now
        visible_: bar.clockHovered
    }
}

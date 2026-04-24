import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar

    // ── Properties ────────────────────────────────────────────────────────────

    property QtObject theme
    property int      activeTag:       1
    property var      occupiedTags:    [1]
    property string   clockText:       ""
    property string   dateText:        ""
    property int      batteryCapacity: 100
    property string   batteryStatus:   "Unknown"
    property bool     clockHovered:    clockArea.containsMouse

    signal toggleSystem()
    signal toggleBluetooth()
    signal toggleVolume()
    signal toggleNetwork()

    // ── Window ────────────────────────────────────────────────────────────────

    anchors.bottom:   true
    anchors.left:  true
    anchors.right: true
    implicitHeight: 24
    color: "transparent"

    // ── Battery helper ────────────────────────────────────────────────────────

    function batteryIcon() {
        if (batteryStatus === "Charging") return "\uf0e7"
        if (batteryStatus === "Full")     return "\uf240"
        if (batteryCapacity > 80) return "\uf240"
        if (batteryCapacity > 60) return "\uf241"
        if (batteryCapacity > 40) return "\uf242"
        if (batteryCapacity > 20) return "\uf243"
        return "\uf244"
    }

    // ── UI ────────────────────────────────────────────────────────────────────

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        RowLayout {
            anchors.fill:        parent
            anchors.leftMargin:  6
            anchors.rightMargin: 12
            spacing: 0

            // ── Left ──────────────────────────────────────────────────────────

            // Void Linux icon → System panel
            BarButton {
                iconColor:  theme.cFg
                hoverColor: theme.cBg2
                icon:       "\uf32e"
                size:       15
                onClicked:  bar.toggleSystem()
            }

            // Center spacer
            Item { Layout.fillWidth: true }

            // ── Center ────────────────────────────────────────────────────────

            Text {
                visible:        occupiedTags.length > 1
                text:           activeTag.toString()
                color:          theme.cFg
                font.family:    "Inter"
                font.pixelSize: 13
                font.bold:      true
                Layout.alignment: Qt.AlignVCenter
            }

            // Center spacer
            Item { Layout.fillWidth: true }

            // ── Right ─────────────────────────────────────────────────────────

            // Bluetooth
            BarButton {
                iconColor:  theme.cFg
                hoverColor: theme.cBg2
                icon:       "\uf294"
                onClicked:  bar.toggleBluetooth()
            }

            Item { implicitWidth: 8 }

            // Volume
            BarButton {
                iconColor:  theme.cFg
                hoverColor: theme.cBg2
                icon:       "\uf028"
                onClicked:  bar.toggleVolume()
            }

            Item { implicitWidth: 8 }

            // Network
            BarButton {
                iconColor:  theme.cFg
                hoverColor: theme.cBg2
                icon:       "\uf1eb"
                onClicked:  bar.toggleNetwork()
            }

            Item { implicitWidth: 12 }

            // Battery
            Text {
                text:           batteryIcon() + "   " + batteryCapacity + "%"
                color:          theme.cFg
                font.family:    "Inter"
                font.pixelSize: 13
                font.bold:      true
                Layout.alignment: Qt.AlignVCenter
            }

            Item { implicitWidth: 12 }

            // Clock
            Text {
                id: clockText_
                text:           clockText
                color:          theme.cFg
                font.family:    "Inter"
                font.pixelSize: 13
                font.bold:      true
                Layout.alignment: Qt.AlignVCenter

                MouseArea { id: clockArea; anchors.fill: parent; hoverEnabled: true }
            }
        }
    }
}

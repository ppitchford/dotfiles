import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar

    // ── Properties ────────────────────────────────────────────────────────────

    property int      activeTag:       1
    property var      occupiedTags:    [1]
    property string   clockText:       ""
    property string   dateText:        ""
    property string   tzName:          ""
    property int      batteryCapacity: 100
    property string   batteryStatus:   "Unknown"
    property bool     clockHovered:    clockArea.containsMouse

    signal toggleSystem()
    signal toggleBluetooth()
    signal toggleVolume()
    signal toggleNetwork()

    // ── Window ────────────────────────────────────────────────────────────────

    anchors.top:   true
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
                icon:    "\uf32e"
                size:    15
                onClicked: bar.toggleSystem()
            }

            // Center spacer
            Item { Layout.fillWidth: true }

            // ── Center ────────────────────────────────────────────────────────

            Text {
                visible:        occupiedTags.length > 1
                text:           activeTag.toString()
                color:          "white"
                font.family:    "Atkinson Hyperlegible"
                font.pixelSize: 13
                font.bold:      true
                Layout.alignment: Qt.AlignVCenter
            }

            // Center spacer
            Item { Layout.fillWidth: true }

            // ── Right ─────────────────────────────────────────────────────────

            // Bluetooth
            BarButton {
                icon:    "\uf294"
                onClicked: bar.toggleBluetooth()
            }

            Item { implicitWidth: 8 }

            // Volume
            BarButton {
                icon:    "\uf028"
                onClicked: bar.toggleVolume()
            }

            Item { implicitWidth: 8 }

            // Network
            BarButton {
                icon:    "\uf1eb"
                onClicked: bar.toggleNetwork()
            }

            Item { implicitWidth: 12 }

            // Battery — icon and readout split so each gets its own font
            Text {
                text:           batteryIcon()
                color:          "white"
                font.family:    "CaskaydiaCove Nerd Font"
                font.pixelSize: 13
                font.bold:      true
                Layout.alignment: Qt.AlignVCenter
            }

            Item { implicitWidth: 6 }

            Text {
                text:           batteryCapacity + "%"
                color:          "white"
                font.family:    "Atkinson Hyperlegible"
                font.pixelSize: 13
                font.bold:      true
                Layout.alignment: Qt.AlignVCenter
            }

            Item { implicitWidth: 12 }

            // Clock
            Item {
                implicitWidth:  clockRow.implicitWidth
                implicitHeight: clockRow.implicitHeight
                Layout.alignment: Qt.AlignVCenter

                Row {
                    id: clockRow
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        id: clockText_
                        text:           clockText
                        color:          "white"
                        font.family:    "Atkinson Hyperlegible"
                        font.pixelSize: 13
                        font.bold:      true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Zone abbreviation, so a timezone change is visible at a glance
                    Text {
                        visible:        tzName !== ""
                        text:           tzName
                        color:          "#99ffffff"
                        font.family:    "Atkinson Hyperlegible"
                        font.pixelSize: 11
                        font.bold:      true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea { id: clockArea; anchors.fill: parent; hoverEnabled: true }
            }
        }
    }
}

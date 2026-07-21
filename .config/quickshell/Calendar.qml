import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: calendar

    required property QtObject theme
    required property bool      visible_

    // Wall clock in the system timezone, carried in the Date's UTC fields.
    // See the clock section of shell.qml — read it with the getUTC* accessors.
    required property var       now

    // ── Window ────────────────────────────────────────────────────────────────

    visible:       visible_
    anchors.top:      true
    anchors.right: true
    implicitWidth:  220
    implicitHeight: calColumn.implicitHeight + 20
    color: "transparent"

    // ── State ─────────────────────────────────────────────────────────────────

    property int  displayYear:  now.getUTCFullYear()
    property int  displayMonth: now.getUTCMonth()

    readonly property var monthNames: [
        "January","February","March","April","May","June",
        "July","August","September","October","November","December"
    ]

    readonly property var dayNames: ["Mo","Tu","We","Th","Fr","Sa","Su"]

    function daysInMonth(year, month) {
        return new Date(Date.UTC(year, month + 1, 0)).getUTCDate()
    }

    function firstDayOfMonth(year, month) {
        const day = new Date(Date.UTC(year, month, 1)).getUTCDay()
        return (day + 6) % 7
    }

    function buildDays() {
        const days   = []
        const first  = firstDayOfMonth(displayYear, displayMonth)
        const total  = daysInMonth(displayYear, displayMonth)
        for (let i = 0; i < first; i++)  days.push(0)
        for (let d = 1; d <= total; d++) days.push(d)
        while (days.length % 7 !== 0)    days.push(0)
        return days
    }

    // ── UI ────────────────────────────────────────────────────────────────────

    Rectangle {
        anchors.fill:  parent
        color:         theme.cBg1
        radius:        8
        border.width:  1
        border.color:  theme.cBorder

        ColumnLayout {
            id: calColumn
            anchors.fill:      parent
            anchors.margins:   12
            spacing: 8

            // Month header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text:           monthNames[displayMonth] + "  " + displayYear
                    color:          theme.cFg
                    font.family:    "Atkinson Hyperlegible"
                    font.pixelSize: 13
                    font.bold:      true
                    Layout.fillWidth: true
                }

            }

            // Day name headers
            Grid {
                columns: 7
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: dayNames
                    delegate: Text {
                        width:          calColumn.width / 7
                        text:           modelData
                        color:          theme.cMuted
                        font.family:    "Atkinson Hyperlegible"
                        font.pixelSize: 11
                        font.bold:      true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Day grid
            Grid {
                columns: 7
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: buildDays()
                    delegate: Rectangle {
                        width:  calColumn.width / 7
                        height: 24
                        radius: 4
                        color: {
                            const isToday = modelData === calendar.now.getUTCDate()
                                && displayMonth === calendar.now.getUTCMonth()
                                && displayYear  === calendar.now.getUTCFullYear()
                            return isToday ? theme.cAccent : "transparent"
                        }

                        Text {
                            anchors.centerIn: parent
                            text:           modelData > 0 ? modelData.toString() : ""
                            color: {
                                const isToday = modelData === calendar.now.getUTCDate()
                                    && displayMonth === calendar.now.getUTCMonth()
                                    && displayYear  === calendar.now.getUTCFullYear()
                                return isToday ? theme.cBg : theme.cFg
                            }
                            font.family:    "Atkinson Hyperlegible"
                            font.pixelSize: 12
                            font.bold:      true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: systemPanel

    required property QtObject theme
    required property bool     visible_

    visible:       visible_
    anchors.top:      true
    anchors.left:  true
    implicitWidth:  200
    implicitHeight: col.implicitHeight + 24
    color: "transparent"

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
                text:           "System"
                color:          theme.cFg
                font.family:    "Atkinson Hyperlegible"
                font.pixelSize: 13
                font.bold:      true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: theme.cBg2 }

            Repeater {
                model: [
                    { label: "\uf186  Suspend",  cmd: ["loginctl", "suspend"] },
                    { label: "\uf023  Lock",     cmd: ["swaylock", "-f"] },
                    { label: "\uf2f5  Logout",   cmd: ["mmsg", "-d", "quit"] },
                    { label: "\uf021  Reboot",   cmd: ["loginctl","reboot"] },
                    { label: "\uf011  Shutdown", cmd: ["loginctl","poweroff"] }
                ]

                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 34
                    radius: 6
                    color:  powerArea.containsMouse ? theme.cRed : theme.cBg2

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left:           parent.left
                        anchors.leftMargin:     12
                        text:           modelData.label
                        color:          powerArea.containsMouse ? theme.cBg : theme.cFg
                        font.family:    "Atkinson Hyperlegible"
                        font.pixelSize: 13
                        font.bold:      true
                    }

                    MouseArea {
                        id: powerArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            systemPanel.visible_ = false
                            Quickshell.execDetached(modelData.cmd)
                        }
                    }
                }
            }
        }
    }
}

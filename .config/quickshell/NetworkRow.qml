import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Column {
    id: networkRow

    required property QtObject theme
    required property var      modelData
    required property QtObject connectProcess

    // Local state — no need to expose to parent
    property string localSsid:     ""
    property string localPassword: ""

    width:   parent.width
    spacing: 4

    // ── Network row ───────────────────────────────────────────────────────────

    Rectangle {
        width:  parent.width
        height: 34
        radius: 6
        color:  rowArea.containsMouse ? theme.cBg2 : theme.cBg1

        RowLayout {
            anchors.fill:    parent
            anchors.margins: 8
            spacing: 8

            Text { text: "\uf1eb"; color: theme.cMuted; font.family: "Inter"; font.pixelSize: 13 }

            Text {
                text: modelData.ssid + (modelData.signal !== "" ? "  " + modelData.signal : "")
                color: theme.cFg; font.family: "Inter"; font.pixelSize: 13
                Layout.fillWidth: true; elide: Text.ElideRight
            }

            Text {
                visible: modelData.security !== "" && modelData.security !== "open"
                text: "\uf084"; color: theme.cMuted; font.family: "Inter"; font.pixelSize: 11
            }
        }

        MouseArea {
            id: rowArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                networkRow.localSsid = modelData.ssid
                if (modelData.security !== "" && modelData.security !== "open") {
                    pwRow.visible = !pwRow.visible
                    if (pwRow.visible) pwField.forceActiveFocus()
                } else {
                    connectProcess.ssid     = modelData.ssid
                    connectProcess.password = ""
                    connectProcess.running  = true
                }
            }
        }
    }

    // ── Password row ──────────────────────────────────────────────────────────

    Rectangle {
        id: pwRow
        visible: false
        width:  parent.width
        height: 34
        radius: 6
        color:  theme.cBg2

        RowLayout {
            anchors.fill:    parent
            anchors.margins: 8
            spacing: 8

            Text { text: "\uf084"; color: theme.cYellow; font.family: "Inter"; font.pixelSize: 13 }

            TextInput {
                id: pwField
                Layout.fillWidth: true
                color: theme.cFg; font.family: "Inter"; font.pixelSize: 13
                echoMode: TextInput.Password
                focus: true
                onTextChanged: networkRow.localPassword = text
                Keys.onReturnPressed: pwRow.doConnect()
                Keys.onEscapePressed: {
                    pwRow.visible         = false
                    networkRow.localPassword = ""
                    text = ""
                }
            }

            Text {
                text: "\uf00c"; color: theme.cYellow; font.family: "Inter"; font.pixelSize: 13
                MouseArea { anchors.fill: parent; onClicked: pwRow.doConnect() }
            }
        }

        function doConnect() {
            connectProcess.ssid     = networkRow.localSsid
            connectProcess.password = networkRow.localPassword
            connectProcess.running  = true
            pwRow.visible           = false
            networkRow.localPassword   = ""
            pwField.text            = ""
        }
    }
}

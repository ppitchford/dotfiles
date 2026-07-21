import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Column {
    id: networkRow

    required property QtObject theme
    required property var      modelData
    required property QtObject panel
    required property bool     saved

    // Local state — no need to expose to parent
    property string localPassword: ""

    readonly property bool secured: modelData.security !== "" && modelData.security !== "open"

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

            Text { text: "\uf1eb"; color: theme.cMuted; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 13 }

            Text {
                text: modelData.ssid + (modelData.signal !== "" ? "  " + modelData.signal : "")
                color: theme.cFg; font.family: "Atkinson Hyperlegible"; font.pixelSize: 13
                Layout.fillWidth: true; elide: Text.ElideRight
            }

            Text {
                visible: networkRow.secured
                text: "\uf084"; color: theme.cMuted; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 11
            }
        }

        MouseArea {
            id: rowArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                // iwd already has the passphrase for a known network — asking
                // for it again was busywork, and got it wrong for open ones.
                if (!networkRow.secured || networkRow.saved) {
                    panel.connectTo(modelData.ssid, "")
                } else {
                    panel.passwordFor = panel.passwordFor === modelData.ssid
                        ? "" : modelData.ssid
                }
            }
        }
    }

    // ── Password row ──────────────────────────────────────────────────────────

    Rectangle {
        id: pwRow
        // Driven by the panel so only one password row is ever open, and so the
        // panel knows to hold the keyboard while it is.
        visible: panel.passwordFor === modelData.ssid
        width:  parent.width
        height: 34
        radius: 6
        color:  theme.cBg2

        onVisibleChanged: {
            if (visible) pwField.forceActiveFocus()
            else { networkRow.localPassword = ""; pwField.text = "" }
        }

        RowLayout {
            anchors.fill:    parent
            anchors.margins: 8
            spacing: 8

            Text { text: "\uf084"; color: theme.cYellow; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 13 }

            TextInput {
                id: pwField
                Layout.fillWidth: true
                color: theme.cFg; font.family: "Atkinson Hyperlegible"; font.pixelSize: 13
                echoMode: TextInput.Password
                onTextChanged: networkRow.localPassword = text
                Keys.onReturnPressed: pwRow.doConnect()
                Keys.onEnterPressed:  pwRow.doConnect()
                Keys.onEscapePressed: panel.passwordFor = ""
            }

            Text {
                text: "\uf00c"; color: theme.cYellow; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 13
                MouseArea { anchors.fill: parent; onClicked: pwRow.doConnect() }
            }
        }

        function doConnect() {
            panel.connectTo(modelData.ssid, networkRow.localPassword)
        }
    }
}

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: btn

    required property string icon

    property int size: 13

    signal clicked()

    implicitWidth:  24
    implicitHeight: 24
    radius: 4
    color:  area.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"
    Layout.alignment: Qt.AlignVCenter

    Text {
        anchors.centerIn: parent
        text:           btn.icon
        color:          "white"
        // Glyph font, not a text font — these are Nerd Font codepoints.
        font.family:    "CaskaydiaCove Nerd Font"
        font.pixelSize: btn.size
        font.bold:      true
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: btn.clicked()
    }
}

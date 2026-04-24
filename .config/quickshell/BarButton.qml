import QtQuick
import QtQuick.Layouts

Rectangle {
    id: btn

    property color iconColor: "white"
    property color hoverColor: "transparent"
    required property string icon
    property int size: 13

    signal clicked()

    implicitWidth:  24
    implicitHeight: 24
    radius: 4
    color:  area.containsMouse ? hoverColor : "transparent"
    Layout.alignment: Qt.AlignVCenter

    Text {
        anchors.centerIn: parent
        text:           btn.icon
        color:          btn.iconColor
        font.family:    "Inter"
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

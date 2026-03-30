import QtQuick
import QtQuick.Layouts

Rectangle {
    id: btn

    required property QtObject theme
    required property string   icon

    property int size: 13

    signal clicked()

    implicitWidth:  24
    implicitHeight: 24
    radius: 4
    color:  area.containsMouse ? theme.cBg2 : "transparent"
    Layout.alignment: Qt.AlignVCenter

    Text {
        anchors.centerIn: parent
        text:           btn.icon
        color:          theme.cFg
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

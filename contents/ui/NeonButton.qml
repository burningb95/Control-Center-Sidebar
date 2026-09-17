import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: 58
    radius: 12

    property string label: ""
    property string icon: ""

    property color idleColor: "#1b1220"
    property color hoverColor: "#24162b"
    property color idleBorderColor: "#39233f"
    property color hoverBorderColor: "#ff2bd6"
    property color iconColor: "#ff2bd6"
    property color labelColor: "#aa9cac"

    signal clicked()

    color: mouseArea.containsMouse ? root.hoverColor : root.idleColor
    border.width: 1
    border.color: mouseArea.containsMouse ? root.hoverBorderColor : root.idleBorderColor

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 3

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.icon
            color: root.iconColor
            font.pixelSize: 18
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.label
            color: root.labelColor
            font.pixelSize: 8
            font.bold: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}

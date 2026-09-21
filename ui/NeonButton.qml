import QtQuick
import QtQuick.Layouts

import "../code" as Code

Rectangle {
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: 58
    radius: 12

    property string label: ""
    property string icon: ""

    property color idleColor: Code.Theme.card
    property color hoverColor: Code.Theme.cardHover
    property color idleBorderColor: Code.Theme.borderColor
    property color hoverBorderColor: Code.Theme.neonPink
    property color iconColor: Code.Theme.neonPink
    property color labelColor: Code.Theme.textSecondary

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

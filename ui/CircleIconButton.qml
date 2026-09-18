import QtQuick
import QtQuick.Effects

import "../code" as Code

Item {
    id: root

    width: 44
    height: 44

    property string icon: ""
    property string iconSource: ""
    property bool active: false
    property color activeColor: Code.Theme.neonCyan
    property color iconColor: Code.Theme.textPrimary
    property string badgeText: ""

    signal clicked()

    MultiEffect {
        anchors.centerIn: iconGroup
        width: iconGroup.width * 2.6
        height: iconGroup.height * 2.6
        source: iconGroup
        visible: root.active
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        colorization: 1.0
        colorizationColor: root.activeColor
        opacity: 1.0
    }

    MultiEffect {
        anchors.centerIn: iconGroup
        width: iconGroup.width * 1.6
        height: iconGroup.height * 1.6
        source: iconGroup
        visible: root.active
        blurEnabled: true
        blur: 0.5
        blurMax: 20
        colorization: 1.0
        colorizationColor: root.activeColor
        opacity: 1.0
    }

    MultiEffect {
        anchors.centerIn: iconGroup
        width: iconGroup.width * 1.1
        height: iconGroup.height * 1.1
        source: iconGroup
        visible: root.active
        blurEnabled: true
        blur: 0.2
        blurMax: 6
        colorization: 1.0
        colorizationColor: root.activeColor
        opacity: 1.0
    }

    Item {
        id: iconGroup
        anchors.centerIn: parent
        width: parent.width * 0.6
        height: parent.height * 0.6

        Text {
            visible: root.iconSource.length === 0
            anchors.centerIn: parent
            text: root.icon
            color: root.iconColor
            font.pixelSize: 16
        }

        Image {
            visible: root.iconSource.length > 0
            anchors.fill: parent
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            sourceSize.width: width * 2
            sourceSize.height: height * 2
        }
    }

    Rectangle {
        visible: root.badgeText.length > 0
        width: 16
        height: 16
        radius: 8
        color: Code.Theme.neonRed
        border.width: 1
        border.color: Code.Theme.background
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: -2
        anchors.rightMargin: -2

        Text {
            anchors.centerIn: parent
            text: root.badgeText
            color: Code.Theme.textPrimary
            font.pixelSize: 8
            font.bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}

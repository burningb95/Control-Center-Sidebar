import QtQuick

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

    // Active state is shown as a backlight: many true circles stacked at
    // increasing scale and exponentially decreasing opacity, approximating
    // a soft radial gradient. This stays perfectly round at any size,
    // unlike a blurred shader effect (MultiEffect), which showed visible
    // square edges at high blur radii. The tight scale range and fine step
    // count keep the halo close to the icon and fuzzy rather than a few
    // visible concentric rings.
    readonly property var _glowLayers: [
        { scale: 1.0, opacity: 0.10 },
        { scale: 1.12, opacity: 0.075 },
        { scale: 1.24, opacity: 0.056 },
        { scale: 1.38, opacity: 0.041 },
        { scale: 1.52, opacity: 0.030 },
        { scale: 1.68, opacity: 0.021 },
        { scale: 1.85, opacity: 0.014 },
        { scale: 2.05, opacity: 0.009 },
        { scale: 2.3, opacity: 0.005 }
    ]

    Repeater {
        model: root._glowLayers

        delegate: Rectangle {
            anchors.centerIn: iconGroup
            width: iconGroup.width * modelData.scale
            height: width
            radius: width / 2
            color: root.activeColor
            opacity: modelData.opacity
            visible: root.active
        }
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

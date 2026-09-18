import QtQuick
import QtQuick.Layouts

import "../code" as Code

RowLayout {
    id: root

    Layout.fillWidth: true
    spacing: 10

    property string icon: ""
    property real value: 0.5
    property color fillColor: Code.Theme.neonRed
    property color trackColor: Code.Theme.card

    signal moved(real value)

    property bool _dragging: false
    property real _dragValue: value
    readonly property real displayValue: _dragging ? _dragValue : value

    opacity: root.enabled ? 1.0 : 0.4

    Text {
        text: root.icon
        color: Code.Theme.textPrimary
        font.pixelSize: 14
        Layout.preferredWidth: 18
        horizontalAlignment: Text.AlignHCenter
    }

    Rectangle {
        id: track
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        radius: height / 2
        color: root.trackColor

        Rectangle {
            id: fill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(track.height, track.width * root.displayValue)
            radius: height / 2
            color: root.fillColor
        }

        Rectangle {
            width: 18
            height: 18
            radius: 9
            color: Code.Theme.textPrimary
            anchors.verticalCenter: track.verticalCenter
            x: Math.min(fill.width, track.width) - width - 6
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.enabled

            function fractionAt(mx) {
                return Math.max(0, Math.min(1, mx / track.width))
            }

            onPressed: (mouse) => {
                root._dragging = true
                root._dragValue = fractionAt(mouse.x)
            }
            onPositionChanged: (mouse) => {
                if (root._dragging) {
                    root._dragValue = fractionAt(mouse.x)
                }
            }
            onReleased: (mouse) => {
                if (root._dragging) {
                    root._dragging = false
                    root.moved(root._dragValue)
                }
            }
        }
    }
}

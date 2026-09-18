import QtQuick
import QtQuick.Layouts

import "../code" as Code

Item {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true

    property int elapsedMs: 0
    property bool running: false
    property double _lastTick: 0

    function formatElapsed() {
        var totalSeconds = Math.floor(root.elapsedMs / 1000)
        var mins = Math.floor(totalSeconds / 60)
        var secs = totalSeconds % 60
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    Timer {
        interval: 200
        running: root.running
        repeat: true
        onTriggered: {
            var now = Date.now()
            root.elapsedMs += now - root._lastTick
            root._lastTick = now
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.formatElapsed()
            color: Code.Theme.textPrimary
            font.pixelSize: 26
            font.bold: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            Rectangle {
                width: 34
                height: 34
                radius: 17
                color: root.running ? Code.Theme.neonRed : Code.Theme.card
                border.width: 1
                border.color: root.running ? Code.Theme.neonRed : Code.Theme.borderColor

                Text {
                    anchors.centerIn: parent
                    text: root.running ? "⏸" : "▶"
                    color: Code.Theme.textPrimary
                    font.pixelSize: 13
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.running) {
                            root.running = false
                        } else {
                            root._lastTick = Date.now()
                            root.running = true
                        }
                    }
                }
            }

            Rectangle {
                width: 34
                height: 34
                radius: 17
                color: Code.Theme.card
                border.width: 1
                border.color: Code.Theme.borderColor

                Text {
                    anchors.centerIn: parent
                    text: "↺"
                    color: Code.Theme.textPrimary
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.running = false
                        root.elapsedMs = 0
                    }
                }
            }
        }
    }
}

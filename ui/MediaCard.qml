import QtQuick
import QtQuick.Layouts

import "../code" as Code

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 12

    property color panelColor: Code.Theme.panel
    property color borderColor: Code.Theme.borderColor
    property color neonRed: Code.Theme.neonRed
    property color neonPurple: Code.Theme.neonPurple
    property color textPrimary: Code.Theme.textPrimary
    property color textSecondary: Code.Theme.textSecondary

    property string trackTitle: "Nothing playing"
    property string trackSubtitle: "No active media player"

    Text {
        text: "NOW PLAYING"
        color: root.textSecondary
        font.pixelSize: 10
        font.bold: true
        font.letterSpacing: 2
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 92
        radius: 14
        color: root.panelColor
        border.width: 1
        border.color: root.borderColor

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 58
                Layout.preferredHeight: 58
                radius: 10

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: root.neonRed
                    }
                    GradientStop {
                        position: 1.0
                        color: root.neonPurple
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "♪"
                    color: Code.Theme.textPrimary
                    font.pixelSize: 28
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    text: root.trackTitle
                    color: root.textPrimary
                    font.pixelSize: 12
                    font.bold: true
                }

                Text {
                    text: root.trackSubtitle
                    color: root.textSecondary
                    font.pixelSize: 9
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 12

    property color panelColor: "#120d16"
    property color borderColor: "#39233f"
    property color neonPink: "#ff2bd6"
    property color neonRed: "#ff1744"
    property color textPrimary: "#f4edf5"
    property color textSecondary: "#aa9cac"

    property string statusText: "ONLINE"
    property string titleText: "Network"
    property string subtitleText: "Connection status"

    Text {
        text: "NETWORK"
        color: root.textSecondary
        font.pixelSize: 10
        font.bold: true
        font.letterSpacing: 2
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 64
        radius: 14
        color: root.panelColor
        border.width: 1
        border.color: root.borderColor

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Text {
                text: "◉"
                color: root.neonPink
                font.pixelSize: 20
            }

            ColumnLayout {
                Layout.fillWidth: true

                Text {
                    text: root.titleText
                    color: root.textPrimary
                    font.pixelSize: 11
                    font.bold: true
                }

                Text {
                    text: root.subtitleText
                    color: root.textSecondary
                    font.pixelSize: 9
                }
            }

            Text {
                text: root.statusText
                color: root.neonRed
                font.pixelSize: 9
                font.bold: true
            }
        }
    }
}

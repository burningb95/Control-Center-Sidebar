import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 12

    property QtObject sysMonitor: null

    property color panelColor: "#120d16"
    property color borderColor: "#39233f"
    property color accentColor: "#ff1744"
    property color textPrimary: "#f4edf5"
    property color textSecondary: "#aa9cac"

    Text {
        text: "SYSTEM"
        color: root.textSecondary
        font.pixelSize: 10
        font.bold: true
        font.letterSpacing: 2
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 112
        radius: 14
        color: root.panelColor
        border.width: 1
        border.color: root.borderColor

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                text: "SYSTEM STATUS"
                color: root.accentColor
                font.pixelSize: 10
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "CPU"
                        color: root.textSecondary
                        font.pixelSize: 10
                    }

                    Text {
                        text: root.sysMonitor && root.sysMonitor.cpuUsage >= 0
                              ? root.sysMonitor.cpuUsage + "%"
                              : "—"
                        color: root.textPrimary
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "RAM"
                        color: root.textSecondary
                        font.pixelSize: 10
                    }

                    Text {
                        text: root.sysMonitor && root.sysMonitor.ramUsage >= 0
                              ? root.sysMonitor.ramUsage + "%"
                              : "—"
                        color: root.textPrimary
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "GPU"
                        color: root.textSecondary
                        font.pixelSize: 10
                    }

                    Text {
                        text: root.sysMonitor && root.sysMonitor.gpuAvailable
                              ? root.sysMonitor.gpuUsage + "%"
                              : "—"
                        color: root.textPrimary
                        font.pixelSize: 18
                        font.bold: true
                    }
                }
            }
        }
    }
}

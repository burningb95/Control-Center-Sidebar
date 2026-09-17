import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.plasmoid

import "../code" as Code

PlasmoidItem {
    id: root

    implicitWidth: 340
    implicitHeight: 720

    Plasmoid.title: "Garuda Neon Sidebar"

    readonly property QtObject sysMonitor: Code.SystemMonitor {}

    property color neonRed: "#ff1744"
    property color neonPink: "#ff2bd6"
    property color neonPurple: "#9c27ff"

    property color background: "#0b080d"
    property color panel: "#120d16"
    property color card: "#1b1220"
    property color cardHover: "#24162b"
    property color textPrimary: "#f4edf5"
    property color textSecondary: "#aa9cac"
    property color borderColor: "#39233f"

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: root.background
        border.width: 1
        border.color: Qt.rgba(
            root.neonPink.r,
            root.neonPink.g,
            root.neonPink.b,
            0.35
        )
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        // Header
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: Qt.formatTime(new Date(), "HH:mm")
                color: root.textPrimary
                font.pixelSize: 34
                font.bold: true
                font.letterSpacing: 1
            }

            Text {
                text: Qt.formatDate(new Date(), "dddd • MMMM d")
                color: root.neonPink
                font.pixelSize: 12
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(
                root.neonPink.r,
                root.neonPink.g,
                root.neonPink.b,
                0.22
            )
        }

        // System section
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
            color: root.panel
            border.width: 1
            border.color: root.borderColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: "SYSTEM STATUS"
                    color: root.neonRed
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
                            text: root.sysMonitor.cpuUsage >= 0
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
                            text: root.sysMonitor.ramUsage >= 0
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
                            text: root.sysMonitor.gpuAvailable
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

        // Now playing
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
            color: root.panel
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
                        color: "white"
                        font.pixelSize: 28
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Text {
                        text: "Nothing playing"
                        color: root.textPrimary
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: "MPRIS integration coming next"
                        color: root.textSecondary
                        font.pixelSize: 9
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // Network
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
            color: root.panel
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
                        text: "Network"
                        color: root.textPrimary
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Text {
                        text: "Connection status"
                        color: root.textSecondary
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "ONLINE"
                    color: root.neonRed
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }

        // Quick actions
        Text {
            text: "QUICK ACTIONS"
            color: root.textSecondary
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 2
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 8
            columnSpacing: 8

            Repeater {
                model: [
                    ["DISPLAY", "☼"],
                    ["WIFI", "⌁"],
                    ["AUDIO", "♫"],
                    ["POWER", "⏻"]
                ]

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58
                    radius: 12
                    color: actionMouse.containsMouse
                           ? root.cardHover
                           : root.card
                    border.width: 1
                    border.color: actionMouse.containsMouse
                                  ? Qt.rgba(
                                        root.neonPink.r,
                                        root.neonPink.g,
                                        root.neonPink.b,
                                        0.45
                                    )
                                  : root.borderColor

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
                            text: modelData[1]
                            color: root.neonPink
                            font.pixelSize: 18
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData[0]
                            color: root.textSecondary
                            font.pixelSize: 8
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        // Footer
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "GARUDA"
                color: root.neonRed
                font.pixelSize: 9
                font.bold: true
                font.letterSpacing: 2
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "NEON SIDEBAR"
                color: root.textSecondary
                font.pixelSize: 8
                font.letterSpacing: 1
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            // Forces the date/time bindings to refresh.
            root.update()
        }
    }
}

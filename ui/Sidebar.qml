import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import org.kde.layershell 1.0 as LayerShell

import "../code" as Code

Window {
    id: root

    property int handleWidth: 8
    property int contentWidth: 340
    property bool pinned: false

    width: shell.width
    height: Screen.height
    color: "transparent"
    flags: Qt.FramelessWindowHint
    visible: true

    LayerShell.Window.anchors: LayerShell.Window.AnchorTop
        | LayerShell.Window.AnchorBottom
        | LayerShell.Window.AnchorRight
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityOnDemand
    LayerShell.Window.exclusionZone: root.handleWidth

    readonly property QtObject sysMonitor: Code.SystemMonitor {}
    readonly property QtObject mediaController: Code.MediaController {}
    readonly property QtObject networkManager: Code.NetworkManager {}
    readonly property QtObject audioManager: Code.AudioManager {}

    onPinnedChanged: {
        if (root.pinned) {
            closeTimer.stop()
            shell.state = "open"
        } else if (!hoverHandler.hovered) {
            closeTimer.restart()
        }
    }

    Timer {
        id: revealTimer
        interval: 100
        onTriggered: shell.state = "open"
    }

    Timer {
        id: closeTimer
        interval: 500
        onTriggered: {
            if (!root.pinned) {
                shell.state = "closed"
            }
        }
    }

    Item {
        id: shell

        x: 0
        y: 0
        height: root.height
        width: root.handleWidth
        state: "closed"

        states: [
            State {
                name: "closed"
                PropertyChanges { shell.width: root.handleWidth }
            },
            State {
                name: "open"
                PropertyChanges { shell.width: root.handleWidth + root.contentWidth }
            }
        ]

        transitions: [
            Transition {
                from: "closed"; to: "open"
                NumberAnimation { target: shell; property: "width"; duration: 220; easing.type: Easing.OutCubic }
            },
            Transition {
                from: "open"; to: "closed"
                NumberAnimation { target: shell; property: "width"; duration: 180; easing.type: Easing.InCubic }
            }
        ]

        HoverHandler {
            id: hoverHandler
            onHoveredChanged: {
                if (hoverHandler.hovered) {
                    closeTimer.stop()
                    if (shell.state === "closed") {
                        revealTimer.restart()
                    }
                } else {
                    revealTimer.stop()
                    if (!root.pinned) {
                        closeTimer.restart()
                    }
                }
            }
        }

        Rectangle {
            id: handle
            width: root.handleWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            color: Code.Theme.neonPink
            opacity: 0.85
        }

        Rectangle {
            id: content
            width: root.contentWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: handle.left
            radius: 22
            color: Code.Theme.background
            border.width: 1
            border.color: Qt.rgba(Code.Theme.neonPink.r, Code.Theme.neonPink.g, Code.Theme.neonPink.b, 0.35)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                Header {
                    Layout.fillWidth: true
                    primaryColor: Code.Theme.textPrimary
                    accentColor: Code.Theme.neonPink
                    pinned: root.pinned
                    onPinToggled: root.pinned = !root.pinned
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(Code.Theme.neonPink.r, Code.Theme.neonPink.g, Code.Theme.neonPink.b, 0.22)
                }

                SystemCard {
                    sysMonitor: root.sysMonitor
                    panelColor: Code.Theme.panel
                    borderColor: Code.Theme.borderColor
                    accentColor: Code.Theme.neonRed
                    textPrimary: Code.Theme.textPrimary
                    textSecondary: Code.Theme.textSecondary
                }

                MediaCard {
                    panelColor: Code.Theme.panel
                    borderColor: Code.Theme.borderColor
                    neonRed: Code.Theme.neonRed
                    neonPurple: Code.Theme.neonPurple
                    textPrimary: Code.Theme.textPrimary
                    textSecondary: Code.Theme.textSecondary

                    trackTitle: root.mediaController.playing && root.mediaController.trackTitle.length > 0
                                ? root.mediaController.trackTitle
                                : "Nothing playing"
                    trackSubtitle: root.mediaController.playing
                                   ? (root.mediaController.trackArtist.length > 0
                                      ? root.mediaController.trackArtist
                                      : "Unknown artist")
                                   : "No active media player"
                }

                NetworkCard {
                    panelColor: Code.Theme.panel
                    borderColor: Code.Theme.borderColor
                    neonPink: Code.Theme.neonPink
                    neonRed: Code.Theme.neonRed
                    textPrimary: Code.Theme.textPrimary
                    textSecondary: Code.Theme.textSecondary

                    statusText: root.networkManager.online ? "ONLINE" : "OFFLINE"
                    subtitleText: root.networkManager.connectionName.length > 0
                                  ? root.networkManager.connectionName
                                  : "No connection"
                }

                QuickActions {
                    panelColor: Code.Theme.card
                    hoverColor: Code.Theme.cardHover
                    borderColor: Code.Theme.borderColor
                    hoverBorderColor: Qt.rgba(Code.Theme.neonPink.r, Code.Theme.neonPink.g, Code.Theme.neonPink.b, 0.45)
                    iconColor: Code.Theme.neonPink
                    labelColor: Code.Theme.textSecondary
                    textSecondary: Code.Theme.textSecondary

                    networkManager: root.networkManager
                    audioManager: root.audioManager
                }

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "GARUDA"
                        color: Code.Theme.neonRed
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "NEON SIDEBAR"
                        color: Code.Theme.textSecondary
                        font.pixelSize: 8
                        font.letterSpacing: 1
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.update()
    }
}

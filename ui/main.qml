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
    readonly property QtObject mediaController: Code.MediaController {}
    readonly property QtObject networkManager: Code.NetworkManager {}
    readonly property QtObject audioManager: Code.AudioManager {}

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

        Header {
            Layout.fillWidth: true
            primaryColor: root.textPrimary
            accentColor: root.neonPink
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

        SystemCard {
            sysMonitor: root.sysMonitor
            panelColor: root.panel
            borderColor: root.borderColor
            accentColor: root.neonRed
            textPrimary: root.textPrimary
            textSecondary: root.textSecondary
        }

        MediaCard {
            panelColor: root.panel
            borderColor: root.borderColor
            neonRed: root.neonRed
            neonPurple: root.neonPurple
            textPrimary: root.textPrimary
            textSecondary: root.textSecondary

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
            panelColor: root.panel
            borderColor: root.borderColor
            neonPink: root.neonPink
            neonRed: root.neonRed
            textPrimary: root.textPrimary
            textSecondary: root.textSecondary

            statusText: root.networkManager.online ? "ONLINE" : "OFFLINE"
            subtitleText: root.networkManager.connectionName.length > 0
                          ? root.networkManager.connectionName
                          : "No connection"
        }

        QuickActions {
            panelColor: root.card
            hoverColor: root.cardHover
            borderColor: root.borderColor
            hoverBorderColor: Qt.rgba(
                root.neonPink.r,
                root.neonPink.g,
                root.neonPink.b,
                0.45
            )
            iconColor: root.neonPink
            labelColor: root.textSecondary
            textSecondary: root.textSecondary

            networkManager: root.networkManager
            audioManager: root.audioManager
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

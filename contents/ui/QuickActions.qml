import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasma5support as P5Support

import "../code" as Code

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 12

    property color panelColor: "#1b1220"
    property color hoverColor: "#24162b"
    property color borderColor: "#39233f"
    property color hoverBorderColor: "#ff2bd6"
    property color iconColor: "#ff2bd6"
    property color labelColor: "#aa9cac"
    property color textSecondary: "#aa9cac"

    property var actions: [
        { label: "DISPLAY", icon: "☼" },
        { label: "WIFI", icon: "⌁" },
        { label: "AUDIO", icon: "♫" },
        { label: "POWER", icon: "⏻" }
    ]

    signal actionTriggered(string label)

    readonly property QtObject networkManager: Code.NetworkManager {}
    readonly property QtObject audioManager: Code.AudioManager {}

    property P5Support.DataSource _launcher: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }

    function _launch(command) {
        _launcher.connectSource(command)
    }

    function handleAction(label) {
        switch (label) {
        case "DISPLAY":
            root._launch("systemsettings kcm_kscreen")
            break
        case "WIFI":
            root.networkManager.toggleWifi()
            break
        case "AUDIO":
            root.audioManager.toggleMute()
            break
        case "POWER":
            root._launch("plasma-shutdown")
            break
        }
    }

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
            model: root.actions

            delegate: NeonButton {
                label: modelData.label
                icon: modelData.icon
                idleColor: root.panelColor
                hoverColor: root.hoverColor
                idleBorderColor: root.borderColor
                hoverBorderColor: root.hoverBorderColor
                iconColor: root.iconColor
                labelColor: root.labelColor

                onClicked: {
                    root.actionTriggered(modelData.label)
                    root.handleAction(modelData.label)
                }
            }
        }
    }
}

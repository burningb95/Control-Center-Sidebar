import QtQuick
import QtQuick.Layouts

import "../code" as Code

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 12

    property color panelColor: Code.Theme.card
    property color hoverColor: Code.Theme.cardHover
    property color borderColor: Code.Theme.borderColor
    property color hoverBorderColor: Code.Theme.neonPink
    property color iconColor: Code.Theme.neonPink
    property color textSecondary: Code.Theme.textSecondary

    property var actions: [
        { label: "DISPLAY", icon: "☼" },
        { label: "WIFI", icon: "⌁" },
        { label: "AUDIO", icon: "♫" },
        { label: "POWER", icon: "⏻" }
    ]

    property QtObject networkManager: null
    property QtObject audioManager: null

    property QtObject _launcher: Code.CommandRunner {}

    function _launch(command) {
        _launcher.run(command)
    }

    function handleAction(label) {
        switch (label) {
        case "DISPLAY":
            root._launch("systemsettings kcm_kscreen")
            break
        case "WIFI":
            if (root.networkManager) {
                root.networkManager.toggleWifi()
            }
            break
        case "AUDIO":
            if (root.audioManager) {
                root.audioManager.toggleMute()
            }
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
                labelColor: root.textSecondary

                onClicked: root.handleAction(modelData.label)
            }
        }
    }
}

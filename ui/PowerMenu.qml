import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import "../code" as Code

Window {
    id: powerMenu

    property QtObject sidebar: null

    width: 220
    height: 220
    minimumWidth: 220
    minimumHeight: 220
    maximumWidth: 220
    maximumHeight: 220
    color: Code.Theme.background
    title: "Power"

    component PowerButton: Rectangle {
        id: btn

        Layout.fillWidth: true
        Layout.preferredHeight: 36
        radius: 10
        property string label: ""
        property bool accent: false
        color: mouse.containsMouse
               ? Code.Theme.cardHover
               : (btn.accent ? Qt.rgba(Code.Theme.neonRed.r, Code.Theme.neonRed.g, Code.Theme.neonRed.b, 0.18) : Code.Theme.card)
        border.width: 1
        border.color: btn.accent ? Code.Theme.neonRed : Code.Theme.borderColor

        signal activated()

        Text {
            anchors.centerIn: parent
            text: btn.label
            color: btn.accent ? Code.Theme.neonRed : Code.Theme.textPrimary
            font.pixelSize: 12
            font.bold: true
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: btn.activated()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        PowerButton {
            label: "Logout"
            onActivated: {
                powerMenu.sidebar.launch("qdbus6 org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.closeSession")
                powerMenu.close()
            }
        }

        PowerButton {
            label: "Restart"
            onActivated: {
                powerMenu.sidebar.launch("systemctl reboot")
                powerMenu.close()
            }
        }

        PowerButton {
            label: "Shutdown"
            accent: true
            onActivated: {
                powerMenu.sidebar.launch("systemctl poweroff")
                powerMenu.close()
            }
        }

        Item {
            Layout.fillHeight: true
        }

        PowerButton {
            label: "Cancel"
            onActivated: powerMenu.close()
        }
    }

    onActiveChanged: {
        if (!powerMenu.active) {
            powerMenu.close()
        }
    }

    onClosing: powerMenu.destroy()
}

import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import "../code" as Code

Window {
    id: settingsWindow

    property QtObject sidebar: null

    width: 340
    height: 460
    minimumWidth: 300
    minimumHeight: 420
    color: Code.Theme.background
    title: "Sidebar Settings"

    component SettingRow: ColumnLayout {
        id: row

        Layout.fillWidth: true
        spacing: 4

        property string label: ""
        property real value: 0
        property real minValue: 0
        property real maxValue: 1
        property string suffix: ""
        property int decimals: 0
        signal moved(real value)

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: row.label
                color: Code.Theme.textSecondary
                font.pixelSize: 11
            }

            Text {
                text: row.value.toFixed(row.decimals) + row.suffix
                color: Code.Theme.textPrimary
                font.pixelSize: 11
                font.bold: true
            }
        }

        PillSlider {
            Layout.fillWidth: true
            fillColor: Code.Theme.neonPink
            trackColor: Code.Theme.card
            value: (row.value - row.minValue) / (row.maxValue - row.minValue)
            onMoved: (v) => row.moved(row.minValue + v * (row.maxValue - row.minValue))
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 20

        Text {
            text: "Sidebar Settings"
            color: Code.Theme.textPrimary
            font.pixelSize: 16
            font.bold: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Layout"
                color: Code.Theme.neonPink
                font.pixelSize: 11
                font.bold: true
            }

            SettingRow {
                label: "Handle width"
                value: settingsWindow.sidebar ? settingsWindow.sidebar.handleWidth : 0
                minValue: 4
                maxValue: 20
                suffix: " px"
                onMoved: (v) => settingsWindow.sidebar.handleWidth = Math.round(v)
            }

            SettingRow {
                label: "Panel width"
                value: settingsWindow.sidebar ? settingsWindow.sidebar.contentWidth : 0
                minValue: 260
                maxValue: 440
                suffix: " px"
                onMoved: (v) => settingsWindow.sidebar.contentWidth = Math.round(v)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Appearance"
                color: Code.Theme.neonPink
                font.pixelSize: 11
                font.bold: true
            }

            SettingRow {
                label: "Panel opacity"
                value: settingsWindow.sidebar ? settingsWindow.sidebar.panelOpacity : 0
                minValue: 0.4
                maxValue: 1.0
                decimals: 2
                onMoved: (v) => settingsWindow.sidebar.panelOpacity = v
            }

            SettingRow {
                label: "Border opacity"
                value: settingsWindow.sidebar ? settingsWindow.sidebar.panelBorderOpacity : 0
                minValue: 0.0
                maxValue: 1.0
                decimals: 2
                onMoved: (v) => settingsWindow.sidebar.panelBorderOpacity = v
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Timing"
                color: Code.Theme.neonPink
                font.pixelSize: 11
                font.bold: true
            }

            SettingRow {
                label: "Reveal delay"
                value: settingsWindow.sidebar ? settingsWindow.sidebar.revealDelay : 0
                minValue: 0
                maxValue: 800
                suffix: " ms"
                onMoved: (v) => settingsWindow.sidebar.revealDelay = Math.round(v)
            }

            SettingRow {
                label: "Auto-close delay"
                value: settingsWindow.sidebar ? settingsWindow.sidebar.closeDelay : 0
                minValue: 100
                maxValue: 2000
                suffix: " ms"
                onMoved: (v) => settingsWindow.sidebar.closeDelay = Math.round(v)
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Text {
            Layout.alignment: Qt.AlignRight
            text: "Changes apply and save instantly"
            color: Code.Theme.textSecondary
            font.pixelSize: 9
        }
    }
}

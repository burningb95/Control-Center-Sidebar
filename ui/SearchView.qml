import QtQuick
import QtQuick.Layouts

import "../code" as Code

ColumnLayout {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 8

    property QtObject _launcher: Code.CommandRunner {}

    // Single-quotes the whole string and escapes any embedded single quotes,
    // so arbitrary search text can't break out into shell metacharacters
    // (the executable DataSource runs this through a shell).
    function shellQuote(text) {
        return "'" + text.replace(/'/g, "'\\''") + "'"
    }

    function runSearch() {
        var query = input.text.trim()
        if (query.length === 0) {
            return
        }
        root._launcher.run("firedragon --search " + root.shellQuote(query))
        input.text = ""
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            radius: height / 2
            color: Code.Theme.card
            border.width: 1
            border.color: input.activeFocus ? Code.Theme.neonRed : Code.Theme.borderColor

            TextInput {
                id: input
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: TextInput.AlignVCenter
                color: Code.Theme.textPrimary
                font.pixelSize: 11
                clip: true
                selectByMouse: true
                onAccepted: root.runSearch()
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "Search the web…"
                color: Code.Theme.textSecondary
                font.pixelSize: 11
                visible: input.text.length === 0 && !input.activeFocus
            }
        }

        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            radius: 14
            color: Code.Theme.card
            border.width: 1
            border.color: Code.Theme.borderColor

            Image {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: "file:///usr/share/icons/candy-icons/apps/scalable/org.kde.kstars.svg"
                fillMode: Image.PreserveAspectFit
                smooth: true
                sourceSize.width: 32
                sourceSize.height: 32
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.runSearch()
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}

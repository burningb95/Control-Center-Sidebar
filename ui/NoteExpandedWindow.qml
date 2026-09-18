import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import "../code" as Code

Window {
    id: expandedWindow

    property string noteText: ""
    property int noteIndex: -1
    property QtObject notesSection: null

    width: 420
    height: 360
    minimumWidth: 280
    minimumHeight: 200
    color: Code.Theme.background
    title: "Note"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        TextEdit {
            id: editor
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: expandedWindow.noteText
            color: Code.Theme.textPrimary
            font.pixelSize: 13
            wrapMode: TextEdit.Wrap
            clip: true
            selectByMouse: true
            onTextChanged: {
                if (expandedWindow.notesSection && expandedWindow.noteIndex >= 0) {
                    expandedWindow.notesSection.updateText(expandedWindow.noteIndex, text)
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignRight
            text: "Changes save automatically"
            color: Code.Theme.textSecondary
            font.pixelSize: 9
        }
    }

    onClosing: {
        if (expandedWindow.notesSection) {
            expandedWindow.notesSection.persist()
        }
        expandedWindow.destroy()
    }
}

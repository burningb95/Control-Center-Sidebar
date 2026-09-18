import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Qt.labs.settings 1.0

import "../code" as Code

ColumnLayout {
    id: root

    Layout.fillWidth: true
    Layout.topMargin: 8
    spacing: 8

    Settings {
        id: settings
        fileName: "/home/camron/.local/share/garuda-neon-sidebar/notes.conf"
        category: "Notes"
        property string notesJson: "[]"
    }

    ListModel {
        id: notesModel
    }

    function pinnedCount() {
        var count = 0
        for (var i = 0; i < notesModel.count; i++) {
            if (notesModel.get(i).pinned) {
                count++
            } else {
                break
            }
        }
        return count
    }

    function ensureComposeSlot() {
        var pc = root.pinnedCount()
        var hasBlank = false
        for (var i = pc; i < notesModel.count; i++) {
            if (notesModel.get(i).text.length === 0) {
                hasBlank = true
                break
            }
        }
        if (!hasBlank) {
            notesModel.insert(pc, { id: Date.now(), text: "", pinned: false, createdAt: Date.now() })
            if (notesList.currentIndex >= pc) {
                notesList.currentIndex = notesList.currentIndex + 1
            }
        }
    }

    function loadNotes() {
        notesModel.clear()
        var parsed = []
        try {
            parsed = JSON.parse(settings.notesJson)
        } catch (e) {
            parsed = []
        }
        for (var i = 0; i < parsed.length; i++) {
            notesModel.append(parsed[i])
        }
        root.ensureComposeSlot()
    }

    function persist() {
        var out = []
        for (var i = 0; i < notesModel.count; i++) {
            var n = notesModel.get(i)
            if (n.text.length === 0 && !n.pinned) {
                continue
            }
            out.push({ id: n.id, text: n.text, pinned: n.pinned, createdAt: n.createdAt })
        }
        settings.notesJson = JSON.stringify(out)
    }

    function addNote() {
        var pc = root.pinnedCount()
        if (pc < notesModel.count && notesModel.get(pc).text.length === 0) {
            notesList.currentIndex = pc
        } else {
            notesModel.insert(pc, { id: Date.now(), text: "", pinned: false, createdAt: Date.now() })
            notesList.currentIndex = pc
        }
    }

    function removeNote(index) {
        notesModel.remove(index)
        root.ensureComposeSlot()
    }

    function togglePin(index) {
        var wasPinned = notesModel.get(index).pinned
        notesModel.setProperty(index, "pinned", !wasPinned)
        if (!wasPinned) {
            notesModel.move(index, 0, 1)
            if (notesList.currentIndex === index) {
                notesList.currentIndex = 0
            }
        }
    }

    function updateText(index, text) {
        notesModel.setProperty(index, "text", text)
    }

    function resetToFirst() {
        root.ensureComposeSlot()
        notesList.currentIndex = 0
    }

    Component.onCompleted: root.loadNotes()

    Connections {
        target: Qt.application
        function onAboutToQuit() {
            root.persist()
        }
    }

    ListView {
        id: notesList
        Layout.fillWidth: true
        Layout.preferredHeight: 140
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        clip: true
        model: notesModel

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton

            property bool cooling: false

            onWheel: (wheel) => {
                if (cooling) {
                    return
                }
                if (wheel.angleDelta.y < 0 || wheel.angleDelta.x > 0) {
                    notesList.incrementCurrentIndex()
                } else if (wheel.angleDelta.y > 0 || wheel.angleDelta.x < 0) {
                    notesList.decrementCurrentIndex()
                } else {
                    return
                }
                cooling = true
                wheelCooldown.restart()
            }

            Timer {
                id: wheelCooldown
                interval: 250
                onTriggered: parent.cooling = false
            }
        }

        delegate: Item {
            width: notesList.width
            height: notesList.height

            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: 16
                color: Code.Theme.card
                border.width: 1
                border.color: model.pinned
                             ? Qt.rgba(Code.Theme.neonRed.r, Code.Theme.neonRed.g, Code.Theme.neonRed.b, 0.6)
                             : Code.Theme.borderColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Item {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18

                            Text {
                                anchors.centerIn: parent
                                text: "📌"
                                font.pixelSize: 11
                                opacity: model.pinned ? 1.0 : 0.4
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.togglePin(index)
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: notesModel.count > 1
                            text: (index + 1) + "/" + notesModel.count
                            color: Code.Theme.textSecondary
                            font.pixelSize: 9
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Item {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                color: Code.Theme.textSecondary
                                font.pixelSize: 14
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.addNote()
                            }
                        }

                        Item {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18

                            Text {
                                anchors.centerIn: parent
                                text: "⤢"
                                color: Code.Theme.textSecondary
                                font.pixelSize: 12
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var comp = Qt.createComponent("NoteExpandedWindow.qml")
                                    if (comp.status === Component.Ready) {
                                        var win = comp.createObject(root, {
                                            noteText: model.text,
                                            noteIndex: index,
                                            notesSection: root
                                        })
                                        win.show()
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            visible: model.text.length > 0 || model.pinned

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: Code.Theme.textSecondary
                                font.pixelSize: 11
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.removeNote(index)
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text {
                            anchors.fill: parent
                            visible: editor.text.length === 0 && !editor.activeFocus
                            text: "💬  Write something down…."
                            color: Code.Theme.textSecondary
                            font.pixelSize: 11
                        }

                        TextEdit {
                            id: editor
                            anchors.fill: parent
                            text: model.text
                            color: Code.Theme.textPrimary
                            font.pixelSize: 11
                            wrapMode: TextEdit.Wrap
                            clip: true
                            selectByMouse: true
                            onTextChanged: {
                                if (text !== model.text) {
                                    root.updateText(index, text)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

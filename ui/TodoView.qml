import QtQuick
import QtQuick.Layouts

import "../code" as Code

ColumnLayout {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 8

    ListModel {
        id: todoModel
    }

    function addTask() {
        var text = input.text.trim()
        if (text.length === 0) {
            return
        }
        todoModel.append({ text: text, done: false })
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
                onAccepted: root.addTask()
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "Add a task…"
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

            Text {
                anchors.centerIn: parent
                text: "+"
                color: Code.Theme.textPrimary
                font.pixelSize: 14
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.addTask()
            }
        }
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 4
        model: todoModel

        delegate: Item {
            width: ListView.view.width
            height: 22

            RowLayout {
                anchors.fill: parent
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    radius: 4
                    color: model.done ? Code.Theme.neonRed : "transparent"
                    border.width: 1
                    border.color: model.done ? Code.Theme.neonRed : Code.Theme.borderColor

                    Text {
                        anchors.centerIn: parent
                        visible: model.done
                        text: "✓"
                        color: Code.Theme.textPrimary
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: todoModel.setProperty(index, "done", !model.done)
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: model.text
                    color: model.done ? Code.Theme.textSecondary : Code.Theme.textPrimary
                    font.pixelSize: 11
                    font.strikeout: model.done
                    elide: Text.ElideRight
                }

                Rectangle {
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: Code.Theme.textSecondary
                        font.pixelSize: 10
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: todoModel.remove(index)
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: todoModel.count === 0
            text: "No tasks yet"
            color: Code.Theme.textSecondary
            font.pixelSize: 11
            opacity: 0.6
        }
    }
}

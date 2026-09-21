import QtQuick
import QtQuick.Layouts

import "../code" as Code

RowLayout {
    id: root

    Layout.fillWidth: true
    Layout.topMargin: 4
    Layout.preferredHeight: 44
    Layout.maximumHeight: 44
    spacing: 4

    readonly property var weekdayLabels: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    property int weekOffset: 0

    // Centered on today rather than Monday-aligned, so today always sits in
    // the middle slot regardless of which weekday it happens to be.
    function buildWeekDays() {
        var today = new Date()
        today.setHours(0, 0, 0, 0)
        var start = new Date(today)
        start.setDate(today.getDate() - 3 + root.weekOffset * 7)

        var days = []
        for (var i = 0; i < 7; i++) {
            var d = new Date(start)
            d.setDate(start.getDate() + i)
            days.push({
                day: d.getDate(),
                weekday: root.weekdayLabels[(d.getDay() + 6) % 7],
                isToday: d.getTime() === today.getTime()
            })
        }
        return days
    }

    readonly property var weekDays: buildWeekDays()

    Item {
        Layout.preferredWidth: 16
        Layout.fillHeight: true

        Text {
            anchors.centerIn: parent
            text: "‹"
            color: Code.Theme.textSecondary
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.weekOffset -= 1
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        RowLayout {
            anchors.fill: parent
            spacing: 2

            Repeater {
                model: root.weekDays

                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Text {
                        Layout.fillWidth: true
                        text: modelData.weekday
                        color: Code.Theme.textSecondary
                        font.pixelSize: 9
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        opacity: modelData.isToday ? 1.0 : 0.6
                    }

                    Rectangle {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        Layout.alignment: Qt.AlignHCenter
                        radius: 13
                        color: modelData.isToday ? Code.Theme.neonRed : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.day
                            color: Code.Theme.textPrimary
                            font.pixelSize: 11
                            font.bold: modelData.isToday
                        }
                    }
                }
            }
        }

        // Lets the strip page week-to-week on a trackpad/wheel swipe, same
        // cooldown-gated pattern NotesSection uses for its horizontal list.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton

            property bool cooling: false

            onWheel: (wheel) => {
                if (cooling) {
                    return
                }
                if (wheel.angleDelta.y < 0 || wheel.angleDelta.x > 0) {
                    root.weekOffset += 1
                } else if (wheel.angleDelta.y > 0 || wheel.angleDelta.x < 0) {
                    root.weekOffset -= 1
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
    }

    Item {
        Layout.preferredWidth: 16
        Layout.fillHeight: true

        Text {
            anchors.centerIn: parent
            text: "›"
            color: Code.Theme.textSecondary
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.weekOffset += 1
        }
    }
}

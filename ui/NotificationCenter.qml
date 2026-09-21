import QtQuick
import QtQuick.Layouts

import "../code" as Code

ColumnLayout {
    id: root

    Layout.fillWidth: true
    Layout.topMargin: 8
    spacing: 10

    property QtObject notificationsModel: null

    // X position (within this section's width) to centre the empty state on,
    // so it lines up with a specific icon in the toggle row above. Negative
    // means "just centre it on the panel".
    property real alignCenterX: -1

    readonly property int count: notificationsModel ? notificationsModel.count : 0
    readonly property int emptyBadgeSize: 64

    function clearAll() {
        if (!notificationsModel) {
            return
        }
        for (var i = notificationsModel.count - 1; i >= 0; --i) {
            notificationsModel.close(notificationsModel.index(i, 0))
        }
    }

    ColumnLayout {
        Layout.preferredWidth: root.emptyBadgeSize
        Layout.leftMargin: root.alignCenterX >= 0
                           ? Math.max(0, root.alignCenterX - root.emptyBadgeSize / 2)
                           : 0
        Layout.alignment: root.alignCenterX >= 0 ? Qt.AlignLeft : Qt.AlignHCenter
        spacing: 10
        visible: root.count === 0

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: root.emptyBadgeSize
            height: root.emptyBadgeSize
            radius: width / 2
            color: Code.Theme.card
            border.width: 1
            border.color: Code.Theme.borderColor

            Image {
                anchors.centerIn: parent
                width: parent.width * 0.55
                height: parent.height * 0.55
                source: "file:///usr/share/icons/candy-icons/apps/scalable/caja-dropbox.svg"
                fillMode: Image.PreserveAspectFit
                smooth: true
                sourceSize.width: width * 2
                sourceSize.height: height * 2
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "No notifications"
            color: Code.Theme.textSecondary
            font.pixelSize: 12
        }
    }

    ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 160)
        visible: root.count > 0
        clip: true
        spacing: 6
        model: notificationsModel

        delegate: Rectangle {
            width: ListView.view.width
            height: 44
            radius: 10
            color: Code.Theme.card
            border.width: 1
            border.color: Code.Theme.borderColor

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        Layout.fillWidth: true
                        text: model.summary || model.applicationName || "Notification"
                        color: Code.Theme.textPrimary
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: (model.body || "").length > 0
                        text: model.body || ""
                        color: Code.Theme.textSecondary
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }
                }

                Item {
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: Code.Theme.textSecondary
                        font.pixelSize: 10
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: notificationsModel.close(notificationsModel.index(index, 0))
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36
        radius: height / 2
        color: Code.Theme.card
        border.width: 1
        border.color: Code.Theme.borderColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14

            Text {
                Layout.fillWidth: true
                text: root.count + (root.count === 1 ? " notification" : " notifications")
                color: Code.Theme.textSecondary
                font.pixelSize: 11
            }

            Item {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20

                Text {
                    anchors.centerIn: parent
                    text: "🗑"
                    color: Code.Theme.textSecondary
                    font.pixelSize: 13
                    opacity: root.count > 0 ? 1.0 : 0.4
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.count > 0
                    onClicked: root.clearAll()
                }
            }
        }
    }
}

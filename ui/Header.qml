import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    spacing: 2

    property color primaryColor: "white"
    property color accentColor: "pink"
    property bool pinned: false

    signal pinToggled()

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            Layout.fillWidth: true
            text: Qt.formatTime(new Date(), "HH:mm")
            color: root.primaryColor
            font.pixelSize: 34
            font.bold: true
            font.letterSpacing: 1
        }

        Rectangle {
            id: pinButton
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignTop
            radius: 8
            color: root.pinned ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25) : "transparent"
            border.width: 1
            border.color: root.pinned ? root.accentColor : Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.4)

            Text {
                anchors.centerIn: parent
                text: "📌"
                font.pixelSize: 13
                opacity: root.pinned ? 1.0 : 0.5
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.pinToggled()
            }
        }
    }

    Text {
        text: Qt.formatDate(new Date(), "dddd • MMMM d")
        color: root.accentColor
        font.pixelSize: 12
    }
}

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    spacing: 2

    property color primaryColor: "white"
    property color accentColor: "pink"

    Text {
        text: Qt.formatTime(new Date(), "HH:mm")
        color: root.primaryColor
        font.pixelSize: 34
        font.bold: true
        font.letterSpacing: 1
    }

    Text {
        text: Qt.formatDate(new Date(), "dddd • MMMM d")
        color: root.accentColor
        font.pixelSize: 12
    }
}

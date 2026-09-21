import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import org.kde.layershell 1.0 as LayerShell
import org.kde.notificationmanager as NotificationManager

import "../code" as Code

Window {
    id: popupRoot

    property QtObject notificationsModel: null
    property bool suppressed: false

    property int cardWidth: 300
    property int margin: 12

    // Used when a notification doesn't request its own timeout.
    property int defaultTimeoutMs: 5000

    width: cardWidth + margin * 2
    height: Math.max(1, column.implicitHeight + margin * 2)
    color: "transparent"
    flags: Qt.FramelessWindowHint
    visible: toastModel.count > 0

    LayerShell.Window.anchors: LayerShell.Window.AnchorTop | LayerShell.Window.AnchorRight
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone
    LayerShell.Window.exclusionZone: 0

    ListModel {
        id: toastModel
    }

    function rowForId(notifId) {
        if (!popupRoot.notificationsModel) {
            return -1
        }
        for (var i = 0; i < popupRoot.notificationsModel.count; i++) {
            var idx = popupRoot.notificationsModel.index(i, 0)
            if (popupRoot.notificationsModel.data(idx, NotificationManager.Notifications.IdRole) === notifId) {
                return i
            }
        }
        return -1
    }

    // Snapshot the row's data: the toast outlives its position in the model,
    // which shifts as other notifications come and go.
    function addToast(row) {
        var roles = NotificationManager.Notifications
        var idx = popupRoot.notificationsModel.index(row, 0)
        var read = function(role) {
            return popupRoot.notificationsModel.data(idx, role)
        }

        var timeout = read(roles.TimeoutRole)

        toastModel.append({
            notifId: read(roles.IdRole),
            summary: read(roles.SummaryRole) || "",
            body: read(roles.BodyRole) || "",
            appName: read(roles.ApplicationNameRole) || "",
            timeoutMs: (timeout && timeout > 0) ? timeout : popupRoot.defaultTimeoutMs
        })
    }

    function removeToast(notifId) {
        for (var i = 0; i < toastModel.count; i++) {
            if (toastModel.get(i).notifId === notifId) {
                toastModel.remove(i)
                return
            }
        }
    }

    function dismiss(notifId) {
        popupRoot.removeToast(notifId)
        var row = popupRoot.rowForId(notifId)
        if (row >= 0) {
            popupRoot.notificationsModel.close(popupRoot.notificationsModel.index(row, 0))
        }
    }

    Connections {
        target: popupRoot.notificationsModel

        function onRowsInserted(parent, first, last) {
            for (var row = first; row <= last; row++) {
                var idx = popupRoot.notificationsModel.index(row, 0)
                popupRoot.notificationsModel.startTimeout(idx)
                if (!popupRoot.suppressed) {
                    popupRoot.addToast(row)
                }
            }
        }
    }

    ColumnLayout {
        id: column
        x: popupRoot.margin
        y: popupRoot.margin
        width: popupRoot.cardWidth
        spacing: 8

        Repeater {
            model: toastModel

            delegate: Rectangle {
                Layout.fillWidth: true
                implicitHeight: toastContent.implicitHeight + 20
                radius: 14
                color: Code.Theme.panel
                border.width: 1
                border.color: Qt.rgba(Code.Theme.neonRed.r, Code.Theme.neonRed.g, Code.Theme.neonRed.b, 0.45)

                Timer {
                    interval: model.timeoutMs
                    running: true
                    onTriggered: popupRoot.removeToast(model.notifId)
                }

                ColumnLayout {
                    id: toastContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 10
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        visible: text.length > 0
                        text: model.appName
                        color: Code.Theme.neonRed
                        font.pixelSize: 9
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: model.summary
                        color: Code.Theme.textPrimary
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: text.length > 0
                        text: model.body
                        color: Code.Theme.textSecondary
                        font.pixelSize: 10
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: popupRoot.dismiss(model.notifId)
                }
            }
        }
    }
}

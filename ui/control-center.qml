import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import org.kde.layershell 1.0 as LayerShell
import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.plasma5support as P5Support

import "../code" as Code

Window {
    id: root

    property int handleWidth: 8
    property int contentWidth: 320
    property bool pinned: false

    width: shell.width
    height: Screen.height
    color: "transparent"
    flags: Qt.FramelessWindowHint
    visible: true

    LayerShell.Window.anchors: LayerShell.Window.AnchorTop
        | LayerShell.Window.AnchorBottom
        | LayerShell.Window.AnchorLeft
    LayerShell.Window.margins.top: Screen.height / 10
    LayerShell.Window.margins.bottom: Screen.height / 10
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityOnDemand
    LayerShell.Window.exclusionZone: root.handleWidth

    readonly property QtObject audioManager: Code.AudioManager {}
    readonly property QtObject brightnessManager: Code.BrightnessManager {}
    readonly property QtObject gameModeManager: Code.GameModeManager {}
    readonly property QtObject awakeManager: Code.AwakeManager {}
    property bool doNotDisturb: false
    readonly property QtObject notificationsModel: NotificationManager.Notifications {
        showJobs: false
    }

    property P5Support.DataSource _launcher: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }

    function launch(command) {
        root._launcher.connectSource(command)
    }

    function reloadSidebar() {
        root.launch("bash -c 'nohup qml6 /home/camron/.local/share/garuda-neon-sidebar/ui/control-center.qml > /dev/null 2>&1 & disown'")
        _reloadTimer.restart()
    }

    Timer {
        id: _reloadTimer
        interval: 400
        onTriggered: Qt.quit()
    }

    function handleTopAction(action) {
        switch (action) {
        case "restart":
            root.reloadSidebar()
            break
        case "power":
            root.launch("plasma-shutdown")
            break
        case "settings":
            root.launch("systemsettings")
            break
        }
    }

    readonly property date bootTime: new Date(Date.now() - (1 * 86400000 + 11 * 3600000 + 39 * 60000))
    readonly property date today: new Date()
    readonly property var weekdayLabels: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    function formatUptime() {
        var ms = Date.now() - root.bootTime.getTime()
        var days = Math.floor(ms / 86400000)
        var hours = Math.floor((ms % 86400000) / 3600000)
        var mins = Math.floor((ms % 3600000) / 60000)
        return "Up " + days + "d, " + hours + "h, " + mins + "m"
    }

    function buildCalendarDays() {
        var year = root.today.getFullYear()
        var month = root.today.getMonth()
        var daysInMonth = new Date(year, month + 1, 0).getDate()
        var firstDow = (new Date(year, month, 1).getDay() + 6) % 7
        var daysInPrevMonth = new Date(year, month, 0).getDate()

        var cells = []
        for (var i = 0; i < firstDow; i++) {
            cells.push({ day: daysInPrevMonth - firstDow + i + 1, current: false, isToday: false })
        }
        for (var d = 1; d <= daysInMonth; d++) {
            cells.push({ day: d, current: true, isToday: d === root.today.getDate() })
        }
        var remainder = cells.length % 7
        if (remainder > 0) {
            var trailing = 7 - remainder
            for (var t = 1; t <= trailing; t++) {
                cells.push({ day: t, current: false, isToday: false })
            }
        }
        return cells
    }

    readonly property var calendarDays: buildCalendarDays()
    readonly property var monthLabel: Qt.formatDate(root.today, "MMMM yyyy")

    readonly property var calendarTabs: [
        { id: "calendar", iconSource: "file:///usr/share/icons/candy-icons/apps/scalable/gnome-calendar.svg" },
        { id: "todo", iconSource: "file:///usr/share/icons/BeautyLine/actions/scalable/fm-details.svg" },
        { id: "timer", iconSource: "file:///usr/share/icons/BeautyLine/actions/scalable/dino-status-away.svg" },
        { id: "calculator", iconSource: "file:///usr/share/icons/candy-icons/apps/scalable/gnome-calculator.svg" }
    ]
    property string calendarView: "calendar"

    onPinnedChanged: {
        if (root.pinned) {
            closeTimer.stop()
            shell.state = "open"
        } else if (!hoverHandler.hovered) {
            closeTimer.restart()
        }
    }

    Timer {
        id: revealTimer
        interval: 100
        onTriggered: shell.state = "open"
    }

    Timer {
        id: closeTimer
        interval: 500
        onTriggered: {
            if (!root.pinned) {
                shell.state = "closed"
            }
        }
    }

    Item {
        id: shell

        x: 0
        y: 0
        height: root.height
        width: root.handleWidth
        state: "closed"

        onStateChanged: {
            if (state === "open") {
                notesSection.resetToFirst()
            } else if (state === "closed") {
                notesSection.persist()
            }
        }

        states: [
            State {
                name: "closed"
                PropertyChanges { shell.width: root.handleWidth }
            },
            State {
                name: "open"
                PropertyChanges { shell.width: root.handleWidth + root.contentWidth }
            }
        ]

        transitions: [
            Transition {
                from: "closed"; to: "open"
                NumberAnimation { target: shell; property: "width"; duration: 220; easing.type: Easing.OutCubic }
            },
            Transition {
                from: "open"; to: "closed"
                NumberAnimation { target: shell; property: "width"; duration: 180; easing.type: Easing.InCubic }
            }
        ]

        HoverHandler {
            id: hoverHandler
            onHoveredChanged: {
                if (hoverHandler.hovered) {
                    closeTimer.stop()
                    if (shell.state === "closed") {
                        revealTimer.restart()
                    }
                } else {
                    revealTimer.stop()
                    if (!root.pinned) {
                        closeTimer.restart()
                    }
                }
            }
        }

        Rectangle {
            id: handle
            width: root.handleWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            color: Code.Theme.neonRed
            opacity: 0.85
        }

        Rectangle {
            id: content
            width: root.contentWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: handle.right
            radius: 22
            color: Qt.rgba(Code.Theme.background.r, Code.Theme.background.g, Code.Theme.background.b, 0.85)
            border.width: 1
            border.color: Qt.rgba(Code.Theme.neonRed.r, Code.Theme.neonRed.g, Code.Theme.neonRed.b, 0.35)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: "⌁  " + root.formatUptime()
                        color: Code.Theme.textSecondary
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    Repeater {
                        model: [
                            { icon: "↻", action: "restart" },
                            { icon: "⚙", action: "settings" },
                            { icon: "⏻", action: "power" }
                        ]

                        delegate: Item {
                            implicitWidth: label.implicitWidth + 8
                            implicitHeight: label.implicitHeight + 8

                            Text {
                                id: label
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: Code.Theme.textPrimary
                                font.pixelSize: 15
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.handleTopAction(modelData.action)
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    PillSlider {
                        icon: "☀"
                        value: root.brightnessManager.value
                        enabled: root.brightnessManager.available
                        fillColor: Code.Theme.neonRed
                        trackColor: Code.Theme.card
                        onMoved: (v) => root.brightnessManager.setValue(v)
                    }

                    PillSlider {
                        icon: "🔊"
                        value: root.audioManager.volume / 100
                        fillColor: Code.Theme.neonRed
                        trackColor: Code.Theme.card
                        onMoved: (v) => root.audioManager.setVolume(v * 100)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    CircleIconButton {
                        iconSource: "file:///usr/share/icons/candy-icons/apps/scalable/appimagekit-kitty.svg"
                        onClicked: root.launch("qdbus6 org.freedesktop.ScreenSaver /ScreenSaver Lock")
                    }

                    CircleIconButton {
                        iconSource: "file:///usr/share/icons/candy-icons/apps/scalable/stellarium.svg"
                        active: root.doNotDisturb
                        onClicked: root.doNotDisturb = !root.doNotDisturb
                    }

                    CircleIconButton {
                        id: keepAwakeButton
                        iconSource: "file:///usr/share/icons/BeautyLine/apps/scalable/io.github.f3d_app.f3d.svg"
                        active: root.awakeManager.active
                        onClicked: root.awakeManager.toggle()
                    }

                    CircleIconButton {
                        iconSource: "file:///usr/share/icons/candy-icons/apps/scalable/falkon.svg"
                        active: root.gameModeManager.active
                        onClicked: root.gameModeManager.toggle()
                    }

                    CircleIconButton {
                        iconSource: "file:///usr/share/icons/candy-icons/apps/scalable/umbrello.svg"
                        badgeText: root.notificationsModel.count > 0 ? String(root.notificationsModel.count) : ""
                        onClicked: {
                            for (var i = root.notificationsModel.count - 1; i >= 0; --i) {
                                root.notificationsModel.close(root.notificationsModel.index(i, 0))
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                NotificationCenter {
                    notificationsModel: root.notificationsModel
                    alignCenterX: keepAwakeButton.x + keepAwakeButton.width / 2
                }

                NotesSection {
                    id: notesSection
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 14
                    color: Code.Theme.panel
                    border.width: 1
                    border.color: Code.Theme.borderColor

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        StackLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            currentIndex: Math.max(0, root.calendarTabs.findIndex((t) => t.id === root.calendarView))

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: "▾"
                                        color: Code.Theme.textSecondary
                                        font.pixelSize: 12
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: root.monthLabel
                                        color: Code.Theme.textPrimary
                                        font.pixelSize: 13
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    Text {
                                        text: "‹"
                                        color: Code.Theme.textSecondary
                                        font.pixelSize: 13
                                    }

                                    Text {
                                        text: "›"
                                        color: Code.Theme.textSecondary
                                        font.pixelSize: 13
                                    }
                                }

                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 7
                                    rowSpacing: 6
                                    columnSpacing: 2

                                    Repeater {
                                        model: root.weekdayLabels

                                        delegate: Text {
                                            Layout.fillWidth: true
                                            text: modelData
                                            color: Code.Theme.textSecondary
                                            font.pixelSize: 9
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }

                                    Repeater {
                                        model: root.calendarDays

                                        delegate: Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 24
                                            radius: 12
                                            color: modelData.isToday ? Code.Theme.neonRed : "transparent"

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.day
                                                font.pixelSize: 10
                                                color: modelData.isToday
                                                       ? Code.Theme.textPrimary
                                                       : (modelData.current ? Code.Theme.textPrimary : Code.Theme.textSecondary)
                                                opacity: modelData.current ? 1.0 : 0.4
                                            }
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillHeight: true
                                }
                            }

                            TodoView {
                            }

                            TimerView {
                            }

                            CalculatorView {
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Code.Theme.borderColor
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 16

                            Item {
                                Layout.fillWidth: true
                            }

                            Repeater {
                                model: root.calendarTabs

                                delegate: CircleIconButton {
                                    iconSource: modelData.iconSource
                                    active: root.calendarView === modelData.id
                                    width: 32
                                    height: 32
                                    onClicked: root.calendarView = modelData.id
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.update()
    }

    NotificationPopups {
        notificationsModel: root.notificationsModel
        suppressed: root.doNotDisturb
    }
}

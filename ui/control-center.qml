import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import Qt.labs.settings 1.0

import org.kde.layershell 1.0 as LayerShell
import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.plasma5support as P5Support

import "../code" as Code

Window {
    id: root

    property int handleWidth: 8
    property int contentWidth: 320
    property bool pinned: false

    property real panelOpacity: 0.85
    property real panelBorderOpacity: 0.35
    property int revealDelay: 100
    property int closeDelay: 500

    // Explicit fileName: without one, Settings lands in a shared
    // QtProject/Qml Runtime.conf, since qml6 sets no application name.
    Settings {
        id: sidebarSettings
        fileName: Qt.resolvedUrl("../sidebar.conf").toString().replace("file://", "")
        category: "Sidebar"
        property alias handleWidth: root.handleWidth
        property alias contentWidth: root.contentWidth
        property alias panelOpacity: root.panelOpacity
        property alias panelBorderOpacity: root.panelBorderOpacity
        property alias revealDelay: root.revealDelay
        property alias closeDelay: root.closeDelay
    }

    width: shell.width
    height: Screen.height
    color: "transparent"
    flags: Qt.FramelessWindowHint
    visible: true
    title: "Side_bar_control_center"

    LayerShell.Window.anchors: LayerShell.Window.AnchorTop
        | LayerShell.Window.AnchorBottom
        | LayerShell.Window.AnchorLeft
    LayerShell.Window.margins.top: Screen.height / 10
    LayerShell.Window.margins.bottom: Screen.height / 10
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityOnDemand
    LayerShell.Window.exclusionZone: root.handleWidth
    LayerShell.Window.scope: "Side_bar_control_center"

    readonly property QtObject audioManager: Code.AudioManager {}
    readonly property QtObject brightnessManager: Code.BrightnessManager {}
    readonly property QtObject gameModeManager: Code.GameModeManager {}
    readonly property QtObject awakeManager: Code.AwakeManager {}
    property bool doNotDisturb: false
    readonly property QtObject notificationsModel: NotificationManager.Notifications {
        showJobs: false
    }

    property QtObject _launcher: Code.CommandRunner {}

    function launch(command) {
        root._launcher.run(command)
    }

    // KWin-side helper (code/kwin-sidebar-helper.js): registers the
    // Meta+Shift+Space global shortcut and watches for windows covering the
    // activation strip. As a sandboxed layer-shell client the sidebar has no
    // other way to see window state or own a global shortcut, so state comes
    // back over the journal, polled below.
    readonly property string _helperScriptPath: "/home/camron/.local/share/garuda-neon-sidebar/code/kwin-sidebar-helper.js"

    function loadKwinHelper() {
        root.launch("bash -c 'qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript garuda-neon-sidebar-helper >/dev/null 2>&1; ID=$(qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript \"" + root._helperScriptPath + "\" garuda-neon-sidebar-helper); qdbus6 org.kde.KWin \"/Scripting/Script$ID\" org.kde.kwin.Script.run'")
    }

    property bool activationBlocked: false
    property string _lastHotkeyTag: ""

    // journalctl -n 60 | grep used to grab the tail of the WHOLE system
    // journal and filter client-side: on a busy system (network/systemd
    // noise etc.) more than 60 unrelated lines can land between two polls,
    // scrolling the last GARUDA_SIDEBAR_OCCLUSION line out of that window
    // before it's ever read. Once that happens activationBlocked gets stuck
    // on a stale value (usually "false") until the next unrelated
    // windowActivated/currentDesktopChanged fires — which is why hover
    // could reveal the sidebar over another active window. journalctl's own
    // -g/--grep does server-side filtering by message content, and -t plus
    // -n 1 asks it directly for "the most recent GARUDA_SIDEBAR_* line",
    // so it can never be pushed out by unrelated log volume.
    readonly property string _helperPollCommand: "h=$(journalctl -b 0 -t kwin_wayland -g 'GARUDA_SIDEBAR_HOTKEY:' -n 1 --no-pager -o cat 2>/dev/null); o=$(journalctl -b 0 -t kwin_wayland -g 'GARUDA_SIDEBAR_OCCLUSION:' -n 1 --no-pager -o cat 2>/dev/null); printf '%s\\n%s\\n' \"$h\" \"$o\""

    property P5Support.DataSource _helperStatusSource: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const out = (data["stdout"] || "").trim()
            const lines = out.split("\n")
            const hotkeyLine = lines[0] || ""
            const occlusionLine = lines[1] || ""

            const hotkeyMatch = hotkeyLine.match(/GARUDA_SIDEBAR_HOTKEY:(\d+)/)
            if (hotkeyMatch && hotkeyMatch[1] !== root._lastHotkeyTag) {
                root._lastHotkeyTag = hotkeyMatch[1]
                root.forceOpen()
            }

            const occlusionMatch = occlusionLine.match(/GARUDA_SIDEBAR_OCCLUSION:([01])/)
            if (occlusionMatch) {
                root.activationBlocked = occlusionMatch[1] === "1"
            }

            disconnectSource(sourceName)
        }
    }

    Timer {
        id: _helperPollTimer
        interval: 600
        running: true
        repeat: true
        onTriggered: root._helperStatusSource.connectSource(root._helperPollCommand)
    }

    function forceOpen() {
        closeTimer.stop()
        shell.state = "open"
        closeTimer.restart()
    }

    Component.onCompleted: root.loadKwinHelper()

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
            root.openPowerMenu()
            break
        case "settings":
            root.openSettings()
            break
        }
    }

    function openSettings() {
        var comp = Qt.createComponent("SettingsView.qml")
        if (comp.status === Component.Ready) {
            var win = comp.createObject(root, { sidebar: root })
            win.show()
            win.raise()
            win.requestActivate()
        }
    }

    function openPowerMenu() {
        var comp = Qt.createComponent("PowerMenu.qml")
        if (comp.status === Component.Ready) {
            var win = comp.createObject(root, { sidebar: root })
            win.show()
            win.raise()
            win.requestActivate()
        }
    }

    property date currentTime: new Date()

    function formatTime() {
        return Qt.formatTime(root.currentTime, "h:mm AP")
    }

    // Icon sets ship with the system icon themes; see claude.md.
    readonly property string candyIcons: "file:///usr/share/icons/candy-icons/apps/scalable"
    readonly property string beautyLineActions: "file:///usr/share/icons/BeautyLine/actions/scalable"
    readonly property string beautyLineApps: "file:///usr/share/icons/BeautyLine/apps/scalable"

    readonly property var calendarTabs: [
        { id: "todo", iconSource: root.beautyLineActions + "/fm-details.svg" },
        { id: "timer", iconSource: root.beautyLineActions + "/dino-status-away.svg" },
        { id: "calculator", iconSource: root.candyIcons + "/gnome-calculator.svg" },
        { id: "search", iconSource: root.candyIcons + "/org.kde.kstars.svg" }
    ]
    property string calendarView: "todo"

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
        interval: root.revealDelay
        onTriggered: shell.state = "open"
    }

    Timer {
        id: closeTimer
        interval: root.closeDelay
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
                } else {
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
            color: "transparent"
        }

        // Only the bottom third of the invisible handle strip wakes the
        // panel, so an idle cursor grazing the left edge elsewhere on the
        // screen doesn't pop it open — opening takes a deliberate move down.
        Item {
            id: activationZone
            width: root.handleWidth
            height: parent.height / 3
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            HoverHandler {
                id: activationHoverHandler
                onHoveredChanged: {
                    if (activationHoverHandler.hovered) {
                        if (!root.activationBlocked) {
                            closeTimer.stop()
                            if (shell.state === "closed") {
                                revealTimer.restart()
                            }
                        }
                    } else {
                        revealTimer.stop()
                    }
                }
            }
        }

        Rectangle {
            id: content
            width: root.contentWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: handle.right
            radius: 22
            color: Qt.rgba(Code.Theme.background.r, Code.Theme.background.g, Code.Theme.background.b, root.panelOpacity)
            border.width: 1
            border.color: Qt.rgba(Code.Theme.neonRed.r, Code.Theme.neonRed.g, Code.Theme.neonRed.b, root.panelBorderOpacity)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: root.formatTime()
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
                        iconSource: root.beautyLineActions + "/brightness-high-symbolic.svg"
                        value: root.brightnessManager.value
                        enabled: root.brightnessManager.available
                        fillColor: Code.Theme.neonPink
                        trackColor: Code.Theme.card
                        onMoved: (v) => root.brightnessManager.setValue(v)
                    }

                    PillSlider {
                        iconSource: root.beautyLineActions + "/audio-volume-high-symbolic.svg"
                        value: root.audioManager.volume / 100
                        fillColor: Code.Theme.neonPink
                        trackColor: Code.Theme.card
                        onMoved: (v) => root.audioManager.setVolume(v * 100)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    CircleIconButton {
                        iconSource: root.candyIcons + "/appimagekit-kitty.svg"
                        onClicked: root.launch("qdbus6 org.freedesktop.ScreenSaver /ScreenSaver Lock")
                    }

                    CircleIconButton {
                        iconSource: root.candyIcons + "/stellarium.svg"
                        active: root.doNotDisturb
                        onClicked: root.doNotDisturb = !root.doNotDisturb
                    }

                    CircleIconButton {
                        id: keepAwakeButton
                        iconSource: root.beautyLineApps + "/io.github.f3d_app.f3d.svg"
                        active: root.awakeManager.active
                        onClicked: root.awakeManager.toggle()
                    }

                    CircleIconButton {
                        iconSource: root.candyIcons + "/falkon.svg"
                        active: root.gameModeManager.active
                        onClicked: root.gameModeManager.toggle()
                    }

                    CircleIconButton {
                        iconSource: root.candyIcons + "/umbrello.svg"
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

                            TodoView {
                            }

                            TimerView {
                            }

                            CalculatorView {
                            }

                            SearchView {
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

                WeekStrip {
                }
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.update()
            root.currentTime = new Date()
        }
    }

    NotificationPopups {
        notificationsModel: root.notificationsModel
        suppressed: root.doNotDisturb
    }
}

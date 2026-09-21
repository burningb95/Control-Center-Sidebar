import QtQuick
import org.kde.plasma.plasma5support as P5Support

QtObject {
    id: manager

    property int updateInterval: 3000
    property bool active: false

    readonly property string pidFile: "/tmp/garuda-neon-sidebar-gamemode.pid"

    // GameMode is scoped to a registered process rather than being a global
    // switch, so "on" parks a dummy process under gamemoderun and "off" kills
    // it. The pidfile is how the two halves find each other across toggles.
    function toggle() {
        if (manager.active) {
            _command.run(
                "bash -c 'kill $(cat " + manager.pidFile + ") 2>/dev/null; rm -f " + manager.pidFile + "'"
            )
        } else {
            _command.run(
                "bash -c 'gamemoderun sleep infinity & echo $! > " + manager.pidFile + "'"
            )
        }
    }

    property QtObject _command: CommandRunner {}

    readonly property string statusCommand: "gamemoded -s"

    property P5Support.DataSource _status: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const out = data["stdout"] || ""
            manager.active = out.indexOf("is active") !== -1
            disconnectSource(sourceName)
        }
    }

    property Timer _pollTimer: Timer {
        interval: manager.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: manager._status.connectSource(manager.statusCommand)
    }
}

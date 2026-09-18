import QtQuick
import org.kde.plasma.plasma5support as P5Support

QtObject {
    id: manager

    property int updateInterval: 3000
    property bool active: false

    readonly property string pidFile: "/tmp/garuda-neon-sidebar-gamemode.pid"

    function toggle() {
        if (manager.active) {
            _stopper.connectSource(
                "bash -c 'kill $(cat " + manager.pidFile + ") 2>/dev/null; rm -f " + manager.pidFile + "'"
            )
        } else {
            _starter.connectSource(
                "bash -c 'gamemoderun sleep infinity & echo $! > " + manager.pidFile + "'"
            )
        }
    }

    property P5Support.DataSource _starter: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }

    property P5Support.DataSource _stopper: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }

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

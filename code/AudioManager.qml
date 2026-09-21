import QtQuick
import org.kde.plasma.plasma5support as P5Support

QtObject {
    id: manager

    property int updateInterval: 2000

    property int volume: 0
    property bool muted: false

    function toggleMute() {
        _command.run("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    }

    function setVolume(percent) {
        const clamped = Math.max(0, Math.min(100, Math.round(percent)))
        manager.volume = clamped
        _command.run("pactl set-sink-volume @DEFAULT_SINK@ " + clamped + "%")
    }

    property QtObject _command: CommandRunner {}

    readonly property string statusCommand: "bash -c '" +
        "vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP \"[0-9]+(?=%)\" | head -n1); " +
        "mute=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -oP \"(?<=Mute: )(yes|no)\"); " +
        "printf \"%s|||%s\" \"$vol\" \"$mute\"'"

    property P5Support.DataSource _status: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const exitCode = data["exit code"]
            const out = (data["stdout"] || "").trim()
            if (exitCode === 0 && out.length > 0) {
                const parts = out.split("|||")
                const v = parseInt(parts[0], 10)
                if (!isNaN(v)) {
                    manager.volume = v
                }
                manager.muted = parts[1] === "yes"
            }
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

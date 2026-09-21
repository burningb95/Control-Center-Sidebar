import QtQuick
import org.kde.plasma.plasma5support as P5Support

QtObject {
    id: manager

    property int updateInterval: 3000

    property bool available: false
    property int brightness: 0
    property int maxBrightness: 100

    readonly property real value: manager.maxBrightness > 0
                                   ? manager.brightness / manager.maxBrightness
                                   : 0

    readonly property string dbusService: "org.kde.Solid.PowerManagement"
    readonly property string dbusPath: "/org/kde/Solid/PowerManagement/Actions/BrightnessControl"
    readonly property string dbusIface: "org.kde.Solid.PowerManagement.Actions.BrightnessControl"

    function setValue(fraction) {
        if (!manager.available) {
            return
        }
        const clampedFraction = Math.max(0, Math.min(1, fraction))
        const target = Math.round(clampedFraction * manager.maxBrightness)
        manager.brightness = target
        _command.run(
            "qdbus6 " + manager.dbusService + " " + manager.dbusPath + " " +
            manager.dbusIface + ".setBrightness " + target
        )
    }

    readonly property string statusCommand: "bash -c '" +
        "max=$(qdbus6 " + dbusService + " " + dbusPath + " " + dbusIface + ".brightnessMax 2>/dev/null); " +
        "cur=$(qdbus6 " + dbusService + " " + dbusPath + " " + dbusIface + ".brightness 2>/dev/null); " +
        "printf \"%s|||%s\" \"$max\" \"$cur\"'"

    property P5Support.DataSource _status: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const exitCode = data["exit code"]
            const out = (data["stdout"] || "").trim()
            const parts = out.split("|||")
            const max = parseInt(parts[0], 10)
            const cur = parseInt(parts[1], 10)

            if (exitCode === 0 && !isNaN(max) && max > 0 && !isNaN(cur)) {
                manager.maxBrightness = max
                manager.brightness = cur
                manager.available = true
            } else {
                // No backlight (desktop), or PowerDevil unavailable.
                manager.available = false
            }
            disconnectSource(sourceName)
        }
    }

    property QtObject _command: CommandRunner {}

    property Timer _pollTimer: Timer {
        interval: manager.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: manager._status.connectSource(manager.statusCommand)
    }
}

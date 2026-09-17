import QtQuick
import org.kde.plasma.plasma5support as P5Support

QtObject {
    id: manager

    property int updateInterval: 3000

    property bool online: false
    property string connectivity: "unknown"
    property string connectionName: ""

    function toggleWifi() {
        _toggle.connectSource(
            "bash -c 'if [ \"$(nmcli radio wifi)\" = \"enabled\" ]; then nmcli radio wifi off; else nmcli radio wifi on; fi'"
        )
    }

    property P5Support.DataSource _toggle: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }

    readonly property string statusCommand: "bash -c '" +
        "conn=$(nmcli networking connectivity 2>/dev/null); " +
        "name=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep -v \":loopback$\" | head -1 | cut -d: -f1); " +
        "printf \"%s|||%s\" \"$conn\" \"$name\"'"

    property P5Support.DataSource _status: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const exitCode = data["exit code"]
            const out = (data["stdout"] || "")
            if (exitCode === 0 && out.length > 0) {
                const parts = out.split("|||")
                manager.connectivity = parts[0] || "unknown"
                manager.connectionName = parts[1] || ""
                manager.online = (manager.connectivity === "full")
            } else {
                manager.connectivity = "unknown"
                manager.connectionName = ""
                manager.online = false
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

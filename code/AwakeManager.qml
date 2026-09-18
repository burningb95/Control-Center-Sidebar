import QtQuick
import org.kde.plasma.plasma5support as P5Support

QtObject {
    id: manager

    property bool active: false
    property string _cookie: ""

    readonly property string service: "org.kde.Solid.PowerManagement"
    readonly property string path: "/org/kde/Solid/PowerManagement/PolicyAgent"
    readonly property string iface: "org.kde.Solid.PowerManagement.PolicyAgent"

    function toggle() {
        if (manager.active) {
            if (manager._cookie.length > 0) {
                _releaser.connectSource(
                    "qdbus6 " + manager.service + " " + manager.path + " " +
                    manager.iface + ".ReleaseInhibition " + manager._cookie
                )
            }
            manager.active = false
            manager._cookie = ""
        } else {
            _acquirer.connectSource(
                "qdbus6 " + manager.service + " " + manager.path + " " +
                manager.iface + ".AddInhibition 1 garuda-neon-sidebar \"Keep awake (control center)\""
            )
        }
    }

    property P5Support.DataSource _acquirer: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const out = (data["stdout"] || "").trim()
            const exitCode = data["exit code"]
            if (exitCode === 0 && out.length > 0) {
                manager._cookie = out
                manager.active = true
            }
            disconnectSource(sourceName)
        }
    }

    property P5Support.DataSource _releaser: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }
}

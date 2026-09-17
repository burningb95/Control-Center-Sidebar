import QtQuick
import org.kde.plasma.plasma5support as P5Support

QtObject {
    id: manager

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
}

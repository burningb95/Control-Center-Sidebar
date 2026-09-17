import QtQuick
import org.kde.plasma.plasma5support as P5Support

QtObject {
    id: manager

    function toggleMute() {
        _toggle.connectSource("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    }

    property P5Support.DataSource _toggle: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }
}

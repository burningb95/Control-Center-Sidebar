import QtQuick
import org.kde.plasma.plasma5support as P5Support

QtObject {
    id: controller

    property int updateInterval: 2000

    property bool playing: false
    property string trackTitle: ""
    property string trackArtist: ""

    readonly property string queryCommand: "bash -c '" +
        "if command -v playerctl >/dev/null 2>&1 && playerctl status >/dev/null 2>&1; then " +
        "st=$(playerctl status 2>/dev/null); " +
        "t=$(playerctl metadata title 2>/dev/null); " +
        "a=$(playerctl metadata artist 2>/dev/null); " +
        "else st=\"NONE\"; t=\"\"; a=\"\"; fi; " +
        "printf \"%s|||%s|||%s\" \"$st\" \"$t\" \"$a\"'"

    property P5Support.DataSource _source: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const exitCode = data["exit code"]
            const out = (data["stdout"] || "")
            if (exitCode === 0 && out.length > 0) {
                const parts = out.split("|||")
                const status = parts[0] || "NONE"
                controller.playing = (status === "Playing")
                controller.trackTitle = parts[1] || ""
                controller.trackArtist = parts[2] || ""
            } else {
                controller.playing = false
                controller.trackTitle = ""
                controller.trackArtist = ""
            }
            disconnectSource(sourceName)
        }
    }

    property Timer _pollTimer: Timer {
        interval: controller.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: controller._source.connectSource(controller.queryCommand)
    }
}

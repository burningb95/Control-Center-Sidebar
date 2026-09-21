import QtQuick
import org.kde.plasma.plasma5support as P5Support

// Fire-and-forget shell command execution. Nothing reads the output, so the
// source disconnects itself as soon as it reports back; managers that need to
// parse stdout keep their own DataSource instead.
QtObject {
    id: runner

    function run(command) {
        _source.connectSource(command)
    }

    property P5Support.DataSource _source: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }
}

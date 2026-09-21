import QtQuick
import org.kde.plasma.plasma5support as P5Support

QtObject {
    id: monitor

    property int updateInterval: 2000

    property int cpuUsage: -1
    property int ramUsage: -1
    property real ramUsedGB: 0
    property real ramTotalGB: 0
    property int gpuUsage: -1
    property bool gpuAvailable: false

    readonly property string cpuCommand: "bash -c '" +
        "l1=$(head -n1 /proc/stat); sleep 0.3; l2=$(head -n1 /proc/stat); " +
        "read -r _ v1a v2a v3a v4a v5a v6a v7a v8a v9a v10a <<< \"$l1\"; " +
        "read -r _ v1b v2b v3b v4b v5b v6b v7b v8b v9b v10b <<< \"$l2\"; " +
        "t1=$((v1a+v2a+v3a+v4a+v5a+v6a+v7a+v8a+v9a+v10a)); " +
        "t2=$((v1b+v2b+v3b+v4b+v5b+v6b+v7b+v8b+v9b+v10b)); " +
        "dt=$((t2-t1)); di=$((v4b-v4a)); " +
        "if [ \"$dt\" -gt 0 ]; then echo $(( (100*(dt-di))/dt )); else echo 0; fi'"

    readonly property string ramCommand: "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%d %.1f %.1f\", (t-a)*100/t, (t-a)/1048576, t/1048576}' /proc/meminfo"

    readonly property string gpuCommand: "bash -c 'command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits || echo NA'"

    property P5Support.DataSource _cpuSource: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const exitCode = data["exit code"]
            const out = (data["stdout"] || "").trim()
            if (exitCode === 0 && out.length > 0) {
                const value = parseInt(out, 10)
                if (!isNaN(value)) {
                    monitor.cpuUsage = value
                }
            }
            disconnectSource(sourceName)
        }
    }

    property P5Support.DataSource _ramSource: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const exitCode = data["exit code"]
            const out = (data["stdout"] || "").trim()
            if (exitCode === 0 && out.length > 0) {
                const parts = out.split(" ")
                if (parts.length === 3) {
                    monitor.ramUsage = parseInt(parts[0], 10)
                    monitor.ramUsedGB = parseFloat(parts[1])
                    monitor.ramTotalGB = parseFloat(parts[2])
                }
            }
            disconnectSource(sourceName)
        }
    }

    property P5Support.DataSource _gpuSource: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const exitCode = data["exit code"]
            const out = (data["stdout"] || "").trim()
            if (exitCode === 0 && out.length > 0 && out !== "NA") {
                const value = parseInt(out, 10)
                if (!isNaN(value)) {
                    monitor.gpuUsage = value
                    monitor.gpuAvailable = true
                }
            } else {
                monitor.gpuAvailable = false
            }
            disconnectSource(sourceName)
        }
    }

    property Timer _pollTimer: Timer {
        interval: monitor.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            monitor._cpuSource.connectSource(monitor.cpuCommand)
            monitor._ramSource.connectSource(monitor.ramCommand)
            monitor._gpuSource.connectSource(monitor.gpuCommand)
        }
    }
}

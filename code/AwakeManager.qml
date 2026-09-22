import QtQuick
import org.kde.plasma.plasma5support as P5Support

QtObject {
    id: manager

    property int updateInterval: 3000
    property bool active: false

    readonly property string pidFile: "/tmp/garuda-neon-sidebar-awake.pid"

    // Originally held the inhibition via org.kde.Solid.PowerManagement.PolicyAgent
    // AddInhibition(1, ...) ("InterruptSession"). That call succeeds and returns a
    // real cookie, but was confirmed live to NOT stop PowerDevil's own idle-timeout
    // suspend: the toggle showed active (cyan glow held) straight through two
    // PowerDevil-initiated `suspend requested from client ... org_kde_powerde`
    // suspends ~20 minutes apart. Whatever PowerDevil's idle action actually checks,
    // it isn't fully covered by that PolicyAgent inhibition in practice here.
    // systemd-inhibit --mode=block is enforced by logind itself before any suspend
    // request is honored, regardless of which caller asked for it or what PowerDevil
    // thinks it checked, so it can't be silently bypassed the same way — confirmed
    // live via `systemd-inhibit --list` before/after. Same pidfile-tracked
    // background-process pattern as GameModeManager: no `setsid` here, since that
    // adds an extra fork and `$!` then captures the wrong PID (confirmed live — the
    // PID that actually shows up in `systemd-inhibit --list` didn't match `$!` with
    // setsid in front, but does without it).
    function toggle() {
        if (manager.active) {
            _command.run(
                "bash -c 'kill $(cat " + manager.pidFile + ") 2>/dev/null; rm -f " + manager.pidFile + "'"
            )
        } else {
            _command.run(
                "bash -c 'systemd-inhibit --what=sleep:idle --mode=block " +
                "--who=garuda-neon-sidebar --why=\"Keep awake (control center)\" " +
                "sleep infinity < /dev/null > /dev/null 2>&1 & echo $! > " + manager.pidFile + "'"
            )
        }
    }

    property QtObject _command: CommandRunner {}

    // Verifies the held process (and therefore the inhibition, which logind drops
    // the moment its fd closes) is still actually alive, rather than trusting the
    // toggle's optimistic UI state — mirrors GameModeManager's real-state polling.
    readonly property string statusCommand: "bash -c 'p=$(cat " + manager.pidFile + " 2>/dev/null); " +
        "[ -n \"$p\" ] && kill -0 \"$p\" 2>/dev/null && echo active || echo inactive'"

    property P5Support.DataSource _status: P5Support.DataSource {
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            const out = data["stdout"] || ""
            manager.active = out.indexOf("active") === 0
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

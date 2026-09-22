# Garuda Neon Sidebar

A neon-themed, hover-reveal system sidebar for KDE Plasma on KWin/Wayland. It docks to the left edge
of the screen as a standalone [LayerShellQt](https://invent.kde.org/plasma/layer-shell-qt) window (not
a Plasma widget/plasmoid), sliding out from a thin always-present handle strip when you hover near the
bottom-left of the screen.

## Features

- **Hover-reveal panel** — an ~8px handle strip stays docked at the left edge; hovering the bottom
  third of it slides the full panel out, with a pinnable "stay open" mode.
- **Quick settings** — brightness and volume sliders (via PowerDevil / PipeWire-Pulse).
- **Quick toggles** — screen lock, Do Not Disturb, keep-awake (inhibits sleep via PowerDevil), and
  game mode (via GameMode/`gamemoderun`).
- **Notifications** — registers itself as the system's `org.freedesktop.Notifications` D-Bus service
  and renders its own notification center and toast popups.
- **Notes** — a persisted scratch notes panel.
- **Todo / Timer / Calculator / Search** tabs, plus a week-strip calendar view.
- **Settings panel** — adjust handle width, panel width/opacity, and reveal/close timing live, saved
  to `sidebar.conf`.
- **Power menu** and a restart shortcut for reloading the sidebar after making changes.
- **Global hotkey** — `Meta+Shift+Space` force-opens the sidebar even when another window has focus or
  is covering the activation strip, via a companion KWin script.
- **Window-aware activation** — the same KWin script tracks whether a real window is covering the
  activation strip and suppresses hover-to-reveal while it is, so the sidebar doesn't pop out over
  whatever you're doing.

## Requirements

- KDE Plasma on KWin/Wayland with `zwlr_layer_shell_v1` support.
- `qml6` (Qt6 QML runtime) with the `org.kde.layershell`, `org.kde.notificationmanager`, and
  `org.kde.plasma5support` QML modules available.
- KWin scripting enabled (`qdbus6`) — used for the global hotkey and window-occlusion detection.
- CLI tools the backend managers shell out to: `pactl` (audio), `nmcli` (network), `playerctl` (media),
  `gamemoderun`/GameMode (game mode toggle). Brightness and keep-awake go through PowerDevil over
  D-Bus, no extra binary required.
- `journalctl` and `busctl` readable as your user (used for the KWin helper channel and for checking
  notification ownership).

## Running

There's no build step — this is plain QML executed directly by the interpreter:

```sh
qml6 ui/control-center.qml
```

`garuda-neon-sidebar.desktop` is the autostart entry (`NoDisplay=true`,
`X-GNOME-Autostart-enabled=true`); symlink or copy it into `~/.config/autostart/` to launch the sidebar
on login. **Its `Exec=` line hardcodes an absolute path to this checkout** — update it (and the
`_helperScriptPath` property in `ui/control-center.qml`) if you relocate the project.

After editing QML while the sidebar is running, use its restart icon (or kill/relaunch the `qml6`
process manually) to pick up changes — see `CLAUDE.md` for the exact dev-loop commands.

## Configuration

- `sidebar.conf` — `[Sidebar]` section: `handleWidth`, `contentWidth`, `panelOpacity`,
  `panelBorderOpacity`, `revealDelay`, `closeDelay`. Edit in-app via the settings panel, or by hand.
- `notes.conf` — persisted notes as JSON.

Both files are machine-local state and are gitignored.

## Notification ownership caveat

For the sidebar's notification center/toasts to receive anything, Plasma's own notification handling
has to be given up first — both the notification widget instance and plasmashell's own systray/core
claim on `org.freedesktop.Notifications` (removing only one isn't enough; plasmashell re-claims the
name on its own). If notifications stop showing up, check who currently owns the name with:

```sh
busctl --user list | grep Notifications
```

See `CLAUDE.md` for the full explanation and the exact config edit involved.

## Development

See `CLAUDE.md` for architecture notes, established UI/animation conventions, and debugging tips
(logging quirks, multi-monitor screenshotting, the KWin-helper polling channel, etc.).

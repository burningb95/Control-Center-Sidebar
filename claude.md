This project builds neon-themed desktop sidebars for KDE Plasma (Garuda, KWin/
Wayland), implemented as standalone LayerShellQt windows (import org.kde.layershell), 
NOT Plasma widgets/plasmoids — confirmed KWin honors zwlr_layer_shell_v1 for 
third-party clients on this system.

Established conventions:
- Each sidebar is its own top-level Window using LayerShell.Window attached 
  properties (anchors, layer: LayerTop, exclusionZone, keyboardInteractivity: 
  KeyboardInteractivityOnDemand)
- NEVER unmap/remap the layer surface to hide it (known KWin bug: no configure 
  event on remap). Keep the window always mapped; animate an inner content 
  Item's position/clip instead
- Keep a persistent handle strip (~8-10px) always within the window's hit area 
  as the hover trigger zone
- Reveal: ~100ms hover delay, then slide over ~220ms, Easing.OutCubic
- Hide: 500ms Timer on cursor-leave, cancel if re-entered, then ~180ms, 
  Easing.InCubic
- Shared design tokens (neonRed #ff1744, neonPink #ff2bd6, neonPurple #9c27ff, 
  neonCyan #00eaff, background #0b080d, panel #120d16, card #1b1220, 
  cardHover #24162b, textPrimary #f4edf5, textSecondary #aa9cac, 
  borderColor #39233f) live in code/Theme.qml (pragma Singleton), imported 
  everywhere as `import "../code" as Code` then `Code.Theme.<token>`
- Reusable logic modules live under code/ (lowercase — SystemMonitor, 
  MediaController, NetworkManager, AudioManager, BrightnessManager, 
  AwakeManager, GameModeManager)
- code/Theme.qml REQUIRES code/qmldir with `singleton Theme 1.0 Theme.qml`. 
  Without it, Qt6 does not register a plain-directory-imported pragma-Singleton 
  file as an actual singleton — `Code.Theme.neonRed` etc. silently resolve to 
  `undefined` with no crash (colors just fail to bind, rendering wrong/blank). 
  This broke silently for an entire session because of the logging issue below.
- Toggle/active-state icons (CircleIconButton) have no background fill or 
  circle shape — `active: true` instead renders a soft neon glow behind the 
  icon via layered `QtQuick.Effects.MultiEffect` (blur + full colorization, 
  default color Code.Theme.neonCyan). Multiple stacked layers (wide soft halo 
  + tight bright core + thin crisp rim) are needed for the glow to read 
  clearly even in a lit room — a single blurred layer was judged "hard to see."
- Icons are real SVGs from the system icon theme (`/usr/share/icons/<theme>/...`), 
  not Unicode/emoji glyphs — loaded via `Image { source: "file:///..." }`. 
  CircleIconButton supports both `icon` (text glyph, legacy) and `iconSource` 
  (image path); prefer iconSource for anything new. Emoji were explicitly 
  rejected as feeling "elementary."
- control-center.qml (the left sidebar) registers itself as the actual 
  org.freedesktop.Notifications D-Bus service via 
  `import org.kde.notificationmanager`, and renders its own toast popups 
  (NotificationPopups.qml) — this REPLACES Plasma's notification handling 
  while it runs. This only works because Plasma's own notification 
  ownership was deliberately removed (both the desktop widget instance and, 
  critically, plasmashell's own systray/core claim — removing just one 
  wasn't enough; plasmashell re-claims org.freedesktop.Notifications on its 
  own even with no notification widget present anywhere, requiring a hand 
  edit of plasma-org.kde.plasma.desktop-appletsrc + a plasmashell restart). 
  If notifications ever stop showing up, check `busctl --user list | grep 
  Notifications` for who currently owns the name before assuming a code bug.
- Persistence (e.g. NotesSection) uses `Qt.labs.settings` with an explicit 
  `fileName:` pointing at a project-local path. The default (no fileName) 
  writes to a generic shared `~/.config/QtProject/Qml Runtime.conf` because 
  qml6 doesn't set a real organizationName/applicationName. Qt.labs.settings 
  is deprecated in favor of a QtCore Settings type, but that type doesn't 
  actually exist yet in the Qt6 version installed here — recheck before 
  switching.

Debugging/testing this project:
- `qml6` silently routes Qt warnings, binding errors, and singleton failures 
  to journald instead of stderr when run non-interactively (e.g. via a 
  scripted Bash tool call) — always run with 
  `QT_FORCE_STDERR_LOGGING=1 qml6 <file>` when checking for errors, or you 
  will see a clean exit and assume everything works when it doesn't.
- For visual checks, never screenshot the full desktop blindly — this is a 
  multi-monitor setup (one 2560x1440 + one rotated to portrait) and full 
  captures repeatedly grab unrelated windows (file managers, editors, 
  settings panels) instead of the target. Use `spectacle -a -b -n -o <path>` 
  (active-window capture) against an isolated plain `Window {}` test file 
  instead of the real LayerShell window when possible.
- Never edit the live/production .qml files to force a test state (e.g. 
  `sed 's/state: "closed"/state: "open"/'`) — always copy to a scratch 
  directory first. Hit this exactly once: a sed meant for a scratch copy 
  landed on the real control-center.qml and flipped its default panel state.
- To test a real code change against the live sidebar: kill the running 
  `qml6 ui/control-center.qml` process (`pgrep -af "qml6.*control-center"`), 
  relaunch with `nohup qml6 ui/control-center.qml > /tmp/control-center.log 
  2>&1 & disown`, then confirm both `pgrep -af qml6` and (since it's the 
  notification daemon) `busctl --user list | grep org.freedesktop.Notifications` 
  show the new PID.
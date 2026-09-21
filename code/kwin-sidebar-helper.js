// Persistent KWin script for the Garuda Neon Sidebar. Loaded once at sidebar
// startup and left running (see control-center.qml). It has two jobs the
// sandboxed sidebar app can't do itself as a plain Wayland client:
//
// 1. Register a global shortcut (Super+Shift+Space) to force the sidebar
//    open even when another window has focus/covers it.
// 2. Watch whether any substantial window overlaps the sidebar's left-edge
//    activation strip, so the app can suppress hover-to-reveal while
//    something is sitting on top of it.
//
// KWin's scripting engine has no filesystem or setInterval access and no
// bridge for pushing data into an unrelated Wayland client, so both signals
// are relayed the only way available: printing a tagged line, which the
// sidebar polls for via `journalctl`.

var ACTIVATION_ZONE_WIDTH = 24;
var MIN_COVERING_WIDTH = 60;

function computeOccluded() {
    var wins = workspace.stackingOrder;
    for (var i = 0; i < wins.length; i++) {
        var w = wins[i];
        if (w.minimized) {
            continue;
        }
        var g = w.frameGeometry;
        if (g.width <= MIN_COVERING_WIDTH) {
            continue;
        }
        if (g.x < ACTIVATION_ZONE_WIDTH && g.x + g.width > 0) {
            return true;
        }
    }
    return false;
}

var lastOccluded = null;

function reportOcclusion() {
    var occluded = computeOccluded();
    if (occluded !== lastOccluded) {
        lastOccluded = occluded;
        print("GARUDA_SIDEBAR_OCCLUSION:" + (occluded ? "1" : "0"));
    }
}

workspace.windowActivated.connect(reportOcclusion);
workspace.currentDesktopChanged.connect(reportOcclusion);
reportOcclusion();

registerShortcut(
    "GarudaNeonSidebarToggle",
    "Open Garuda Neon Sidebar",
    "Meta+Shift+Space",
    function () {
        print("GARUDA_SIDEBAR_HOTKEY:" + Date.now());
    }
);

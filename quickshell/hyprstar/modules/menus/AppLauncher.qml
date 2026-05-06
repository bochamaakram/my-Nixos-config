import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.theme as Theme

PanelWindow {
    id: win

    property bool open: false
    visible: open
    color: "transparent"

    anchors { left: true; right: true; top: true; bottom: true }
    exclusiveZone: 0

    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // ---- usage storage ----
    readonly property string usagePath: Quickshell.statePath("launcher-usage.json")

    FileView {
        id: usageFile
        path: win.usagePath
        preload: true
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: usage
            property var counts: ({}) // { "<id>": { count: number, last: number } }
        }
    }

    function usageCount(appId) {
        const c = usage.counts || ({});
        const v = c[appId];
        return (v && typeof v.count === "number") ? v.count : 0;
    }

    function bumpUsage(appId) {
        const c0 = usage.counts || ({});
        const prev = c0[appId] || ({ count: 0, last: 0 });

        const c = Object.assign({}, c0);
        c[appId] = {
            count: (typeof prev.count === "number" ? prev.count : 0) + 1,
            last: Date.now()
        };

        usage.counts = c; // adapterUpdated -> writeAdapter()
    }

    // ---- matching ----
    function isSubsequence(q, s) {
        let i = 0;
        for (let j = 0; j < s.length && i < q.length; j++) {
            if (s[j] === q[i]) i++;
        }
        return i === q.length;
    }

    function matchScore(entry, q) {
        if (!q || q.length === 0) return 0;

        const name = (entry.name || "").toLowerCase();
        const gen  = (entry.genericName || "").toLowerCase();
        const comm = (entry.comment || "").toLowerCase();
        const kws  = (entry.keywords || []).join(" ").toLowerCase();
        const hay  = name + " " + gen + " " + comm + " " + kws;

        if (name.startsWith(q)) return 100000 + q.length * 80;

        const idx = name.indexOf(q);
        if (idx !== -1) return 70000 + q.length * 50 - idx * 20;

        if (gen.includes(q))  return 30000 + q.length * 25;
        if (kws.includes(q))  return 24000 + q.length * 20;
        if (comm.includes(q)) return 18000 + q.length * 15;

        if (isSubsequence(q, hay)) return 7000 + q.length * 10;

        return -1;
    }

    // ---- IPC ----
    IpcHandler {
        target: "launcher"
        function toggle(): void { win.open = !win.open; }
        function open(): void { win.open = true; }
        function close(): void { win.open = false; }
    }

    function closeLauncher() {
        open = false;
        panel.query = "";
    }

    function moveSelection(delta) {
        if (list.count <= 0) { list.currentIndex = -1; return; }
        const next = Math.max(0, Math.min(list.count - 1, list.currentIndex + delta));
        list.currentIndex = next;
        list.positionViewAtIndex(next, ListView.Contain);
    }

    // Most reliable: call the delegate's run() on the current item.
    function launchSelected() {
        if (!list.currentItem || !list.currentItem.run) return;
        list.currentItem.run();
    }

    // global fallback
    Keys.onPressed: (e) => {
        if (!open) return;
        if (e.key === Qt.Key_Escape) { closeLauncher(); e.accepted = true; return; }
        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { launchSelected(); e.accepted = true; return; }
    }

    // ---- backdrop ----
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0

        MouseArea {
            anchors.fill: parent
            onClicked: win.closeLauncher()
        }
    }

    // ---- panel ----
    Rectangle {
        id: panel
        width: Math.min(parent.width - 80, 500)
        height: Math.min(parent.height - 120, 350)
        radius: 18
        color: Theme.Theme.bg
        border.width: 1
        border.color: Theme.Theme.border
        anchors.centerIn: parent
        antialiasing: true

        property string query: ""
        onQueryChanged: {
            list.currentIndex = list.count > 0 ? 0 : -1;
            if (list.currentIndex >= 0) list.positionViewAtBeginning();
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            TextField {
                id: search
                Layout.fillWidth: true
                height: 48

                text: panel.query
                onTextEdited: panel.query = text

                placeholderText: "Search Applications"
                font.pixelSize: 15

                // Force consistent colors (these override theme palette weirdness)
                color: Theme.Theme.text
                placeholderTextColor: Theme.Theme.subText
                selectionColor: "#45475a"
                selectedTextColor: Theme.Theme.text
                cursorDelegate: Rectangle {
                    width: 2
                    color: Theme.Theme.accent
                    radius: 1
                }

                leftPadding: 14
                rightPadding: 12
                topPadding: 12
                bottomPadding: 12

                background: Rectangle {
                    radius: 14
                    color: Theme.Theme.bttnbg
                    border.width: 1
                    border.color: search.activeFocus ? Theme.Theme.accent : Theme.Theme.bttnbg

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: 13
                        color: "transparent"
                        border.width: 1
                        border.color: search.activeFocus ? Theme.Theme.accent : Theme.Theme.bttnbg
                    }
                }

                // Make Enter guaranteed while typing
                Keys.onPressed: (e) => {
                    if (e.key === Qt.Key_Escape) { win.closeLauncher(); e.accepted = true; return; }
                    if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { win.launchSelected(); e.accepted = true; return; }
                    if (e.key === Qt.Key_Down) { win.moveSelection(1); e.accepted = true; return; }
                    if (e.key === Qt.Key_Up) { win.moveSelection(-1); e.accepted = true; return; }
                }

                onAccepted: win.launchSelected()
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2
                clip: true

                currentIndex: 0

                // Optional: stop the rubber-band bounce at ends
                boundsBehavior: Flickable.StopAtBounds

                // Disable built-in highlight
                highlight: null
                highlightFollowsCurrentItem: false

                // Sliding highlight that lives INSIDE the scrollable content
                Rectangle {
                    id: slideHl
                    radius: 12
                    color: Theme.Theme.accent

                    // Put it behind the delegates so text stays visible
                    z: -1

                    // Animated target geometry
                    property real ty: 0
                    property real th: 44

                    x: 0
                    width: list.width
                    y: ty
                    height: th
                    visible: list.currentIndex >= 0 && list.currentItem !== null

                    Behavior on ty { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                    Behavior on th { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                    Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                    function syncToCurrent() {
                        if (!list.currentItem) return;
                        ty = list.currentItem.y;
                        th = list.currentItem.height;
                    }

                    Component.onCompleted: {
                        // IMPORTANT: move highlight into the scrolling content space
                        slideHl.parent = list.contentItem;
                        slideHl.syncToCurrent();
                    }
                }

                onCurrentItemChanged: slideHl.syncToCurrent()

                model: ScriptModel {
                    values: {
                        const q = panel.query.trim().toLowerCase();

                        const apps = [...DesktopEntries.applications.values];
                        let scored = [];

                        for (const a of apps) {
                            const m = win.matchScore(a, q);
                            if (q.length > 0 && m < 0) continue;

                            const u = win.usageCount(a.id);
                            const key = (q.length > 0) ? (m * 1000000000000 + u) : u;

                            scored.push({ app: a, key: key });
                        }

                        scored.sort((x, y) => {
                        if (x.key !== y.key) return y.key - x.key;
                            return (x.app.name || "").localeCompare(y.app.name || "");
                        });

                        return scored.map(x => x.app);
                    }
                }

                Keys.onPressed: (e) => {
                    if (e.key === Qt.Key_Escape) { win.closeLauncher(); e.accepted = true; return; }
                    if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { win.launchSelected(); e.accepted = true; return; }
                    if (e.key === Qt.Key_Down) { win.moveSelection(1); e.accepted = true; return; }
                    if (e.key === Qt.Key_Up) { win.moveSelection(-1); e.accepted = true; return; }
                }

                delegate: Item {
                    id: row
                    width: list.width
                    height: 44

                    function run() {
                        win.bumpUsage(modelData.id);
                        modelData.execute();
                        win.closeLauncher();
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: list.currentIndex = index
                        onClicked: {
                            list.currentIndex = index;
                            row.run();
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10
            
                        IconImage {
                            width: 22
                            height: 22
                            source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: (index === list.currentIndex) ? Theme.Theme.bg : Theme.Theme.text
                            elide: Text.ElideRight
                            font.pixelSize: 15
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            panel.query = "";
            Qt.callLater(() => {
                search.forceActiveFocus();
                list.currentIndex = list.count > 0 ? 0 : -1;
            });
        }
    }
}

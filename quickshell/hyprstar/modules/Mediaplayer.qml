import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.services as Services
import qs.theme as Theme

Item {
    id: root
    implicitHeight: 96
    Layout.fillWidth: true

    readonly property var m: Services.Mpris

    // Theme colors
    property color bg: Theme.Theme.bttnbg
    property color border: Theme.Theme.border
    property color text: Theme.Theme.text
    property color subtext: Theme.Theme.gridBttn_off_subt
    property color accent: Theme.Theme.accent

    // Playback state
    property bool isPlaying: false

    Process {
        id: statProc
        command: ["bash", "-lc", "playerctl status 2>/dev/null || echo Stopped"]
        stdout: StdioCollector { onStreamFinished: root.isPlaying = (text.trim() === "Playing") }
    }

    Timer {
        interval: 900
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: { statProc.running = false; statProc.running = true }
    }

    Process { id: prevProc; command: ["playerctl", "previous"] }
    Process { id: nextProc; command: ["playerctl", "next"] }
    Process { id: seekProc }

    // Loop repeat state
    property string loopMode: "None" // "None" | "Playlist" | "Track"
    Process { id: loopSetProc }
    Process {
        id: loopGetProc
        command: ["bash", "-lc", "playerctl loop 2>/dev/null || echo None"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim()
                root.loopMode = (v === "Track" || v === "Playlist" || v === "None") ? v : "None"
            }
        }
    }

    function cycleLoop() {
        const next = (loopMode === "None") ? "Playlist"
                   : (loopMode === "Playlist") ? "Track"
                   : "None"
        loopMode = next
        loopSetProc.command = ["playerctl", "loop", next]
        loopSetProc.running = false
        loopSetProc.running = true
        loopGetProc.running = false
        loopGetProc.running = true
    }

    Timer {
        interval: 1200
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: { loopGetProc.running = false; loopGetProc.running = true }
    }

    // Seek smoothing
    property bool dragging: false
    property real dragFrac: 0.0
    property bool seekPending: false
    property real pendingSec: 0

    Timer {
        id: pendingTimer
        interval: 1500
        repeat: false
        onTriggered: root.seekPending = false
    }

    function clamp01(x) { return Math.max(0, Math.min(1, x)) }

    function liveFrac() {
        if (m.lengthSec <= 0) return 0
        return clamp01(m.positionSec / m.lengthSec)
    }

    Connections {
        target: root.m
        function onPositionSecChanged() {
            if (!root.seekPending) return
            if (Math.abs(root.m.positionSec - root.pendingSec) <= 1.5) {
                root.seekPending = false
                pendingTimer.stop()
            }
        }
    }

    function displayedFrac() {
        if (dragging) return dragFrac
        if (seekPending && m.lengthSec > 0) return clamp01(pendingSec / m.lengthSec)
        return liveFrac()
    }

    function seekToFrac(f) {
        if (m.lengthSec <= 0) return
        const sec = Math.max(0, Math.min(m.lengthSec, Math.round(f * m.lengthSec)))
        pendingSec = sec
        seekPending = true
        pendingTimer.restart()
        seekProc.command = ["playerctl", "position", String(sec)]
        seekProc.running = false
        seekProc.running = true
    }

    // Title marquee state
    property bool titleNeedsMarquee: false
    property int titleFadeW: 12

    component TapArea : MouseArea {
        id: tap
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        property Item targetItem
        property real hoverScale: 1.08
        property real pressScale: 0.92

        onPressedChanged: {
            if (!targetItem) return
            targetItem.scale = pressed ? pressScale : (containsMouse ? hoverScale : 1.0)
        }
        onContainsMouseChanged: {
            if (!targetItem || pressed) return
            targetItem.scale = containsMouse ? hoverScale : 1.0
        }
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16
        color: root.bg
        border.width: 1
        border.color: root.border
        clip: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12

            // Cover Art Frame
            Item {
                implicitWidth: 76
                implicitHeight: 76
                Layout.alignment: Qt.AlignVCenter

                ClippingRectangle {
                    anchors.fill: parent
                    radius: 10
                    antialiasing: true

                    Rectangle {
                        anchors.fill: parent
                        color: "#2a2b3a"
                    }

                    Image {
                        anchors.fill: parent
                        source: m.artUrl
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        mipmap: true
                        visible: (m.artUrl && m.artUrl.length > 0)
                    }
                }
            }

            // Info and Controls Column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Item {
                    Layout.fillWidth: true
                    height: 18

                    Item {
                        id: titleViewport
                        anchors.left: parent.left
                        anchors.right: repeatBtn.left
                        anchors.rightMargin: 8
                        height: 18
                        clip: true

                        Row {
                            id: titleRow
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 22
                            x: 0

                            Text {
                                id: titleA
                                text: m.albumTitle || "No Media"
                                color: root.text
                                font.pixelSize: 14
                                font.weight: 700
                                elide: Text.ElideNone
                            }

                            Text {
                                id: titleB
                                text: titleA.text
                                color: root.text
                                font.pixelSize: 14
                                font.weight: 700
                                elide: Text.ElideNone
                                visible: root.titleNeedsMarquee
                            }
                        }

                        // Left and Right fades for marquee text
                        Item {
                            z: 10
                            visible: root.titleNeedsMarquee
                            width: root.titleFadeW
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            clip: true
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.height
                                height: parent.width
                                rotation: -90
                                transformOrigin: Item.Center
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: root.bg }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                            }
                        }

                        Item {
                            z: 10
                            visible: root.titleNeedsMarquee
                            width: root.titleFadeW
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            clip: true
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.height
                                height: parent.width
                                rotation: -90
                                transformOrigin: Item.Center
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 1.0; color: root.bg }
                                }
                            }
                        }

                        Timer {
                            id: titleDelay
                            interval: 900
                            repeat: false
                            onTriggered: { if (root.titleNeedsMarquee) titleAnim.start() }
                        }

                        function recompute(reset) {
                            const usable = Math.max(0, titleViewport.width - root.titleFadeW * 2)
                            root.titleNeedsMarquee = (titleA.paintedWidth > usable)

                            titleAnim.stop()
                            titleDelay.stop()

                            if (reset || !root.titleNeedsMarquee) titleRow.x = 0
                            if (root.titleNeedsMarquee) {
                                titleAnim.from = 0
                                titleAnim.to = -(titleA.paintedWidth + titleRow.spacing)
                                titleDelay.start()
                            }
                        }

                        onWidthChanged: recompute(false)
                        Component.onCompleted: recompute(true)

                        Connections {
                            target: root.m
                            function onAlbumTitleChanged() { titleViewport.recompute(true) }
                        }

                        NumberAnimation {
                            id: titleAnim
                            target: titleRow
                            property: "x"
                            from: 0
                            to: -(titleA.paintedWidth + titleRow.spacing)
                            duration: Math.max(11000, titleA.paintedWidth * 20)
                            loops: Animation.Infinite
                            easing.type: Easing.Linear
                            running: false
                        }
                    }

                    Rectangle {
                        id: repeatBtn
                        width: 20
                        height: 20
                        radius: 6
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        z: 2

                        color: repeatTap.pressed ? "#2a2b3a"
                             : (repeatTap.containsMouse ? "#2f3042" : "transparent")

                        border.width: (root.loopMode === "None") ? 0 : 1
                        border.color: "#45475a"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        transformOrigin: Item.Center
                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                        Text {
                            anchors.centerIn: parent
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 12
                            text: (root.loopMode === "Track") ? "󰑘" : "󰑖"
                            color: root.text
                            opacity: (root.loopMode === "None") ? 0.45 : 0.95
                        }

                        TapArea {
                            id: repeatTap
                            anchors.fill: parent
                            targetItem: repeatBtn
                            onClicked: root.cycleLoop()
                        }
                    }
                }

                Text {
                    text: (m.albumArtist || "No Artist")
                    color: root.subtext
                    opacity: 0.9
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Seeker Bar
                Item {
                    id: bar
                    Layout.fillWidth: true
                    height: 10

                    readonly property int pad: 0
                    readonly property real f: root.displayedFrac()
                    readonly property real usableW: Math.max(1, width - pad * 2)

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: bar.pad
                        width: bar.usableW
                        height: 3
                        radius: 1.5
                        color: "#313244"
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: bar.pad
                        width: Math.max(4, bar.usableW * bar.f)
                        height: 3
                        radius: 1.5
                        color: root.accent
                    }

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: root.text
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.max(
                               bar.pad,
                               Math.min(
                                   bar.pad + bar.usableW - width,
                                   bar.pad + bar.usableW * bar.f - width / 2
                               )
                           )
                        opacity: (m.lengthSec > 0) ? 0.9 : 0.25
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: (m.lengthSec > 0)

                        function updateDrag(mx) { root.dragFrac = root.clamp01((mx - bar.pad) / bar.usableW) }

                        onPressed: { root.dragging = true; updateDrag(mouse.x) }
                        onPositionChanged: { if (root.dragging) updateDrag(mouse.x) }
                        onReleased: {
                            updateDrag(mouse.x)
                            root.dragging = false
                            root.seekToFrac(root.dragFrac)
                        }
                        onCanceled: root.dragging = false
                    }
                }

                // Controls Row
                Item {
                    Layout.fillWidth: true
                    height: 18

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: m.formatTime(
                                root.dragging ? (root.dragFrac * m.lengthSec)
                                             : (root.seekPending ? root.pendingSec : m.positionSec)
                            )
                            color: root.subtext
                            opacity: 0.85
                            font.pixelSize: 10
                        }

                        Item { Layout.fillWidth: true }

                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 12

                            Item {
                                width: 16; height: 16
                                Layout.alignment: Qt.AlignVCenter
                                Text {
                                    id: prevIcon
                                    anchors.centerIn: parent
                                    text: "󰒮"
                                    font.family: "Hack Nerd Font"
                                    font.pixelSize: 14
                                    color: root.text
                                    opacity: 0.9
                                    transformOrigin: Item.Center
                                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                                }
                                TapArea {
                                    anchors.fill: parent
                                    targetItem: prevIcon
                                    onClicked: { prevProc.running = false; prevProc.running = true }
                                }
                            }

                            Item {
                                width: 16; height: 16
                                Layout.alignment: Qt.AlignVCenter
                                Text {
                                    id: playIcon
                                    anchors.centerIn: parent
                                    text: root.isPlaying ? "󰏤" : "󰐊"
                                    font.family: "Hack Nerd Font"
                                    font.pixelSize: 15
                                    color: root.text
                                    opacity: 0.95
                                    transformOrigin: Item.Center
                                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                                }
                                TapArea {
                                    anchors.fill: parent
                                    targetItem: playIcon
                                    onClicked: m.playPause()
                                }
                            }

                            Item {
                                width: 16; height: 16
                                Layout.alignment: Qt.AlignVCenter
                                Text {
                                    id: nextIcon
                                    anchors.centerIn: parent
                                    text: "󰒭"
                                    font.family: "Hack Nerd Font"
                                    font.pixelSize: 14
                                    color: root.text
                                    opacity: 0.9
                                    transformOrigin: Item.Center
                                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                                }
                                TapArea {
                                    anchors.fill: parent
                                    targetItem: nextIcon
                                    onClicked: { nextProc.running = false; nextProc.running = true }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: m.formatTime(m.lengthSec)
                            color: root.subtext
                            opacity: 0.85
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }
    }
}

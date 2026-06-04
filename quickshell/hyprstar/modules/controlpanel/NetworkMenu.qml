import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.services as Services
import qs.theme as Theme

Popup {
    id: menu
    width: 340
    modal: false
    focus: true
    padding: 10
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    opacity: 0

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 140; easing.type: Easing.OutCubic }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 120; easing.type: Easing.OutCubic }
    }

    // Theme
    property color bg: Theme.Theme.bg
    property color border: Theme.Theme.border
    property color text: Theme.Theme.text
    property color subtext: Theme.Theme.gridBttn_off_subt
    property color accent: Theme.Theme.accent

    property string statusText: ""
    property bool wifiEnabled: true

    ListModel { id: wifiModel }

    function wifiIcon(strength, security) {
        var isSecured = security && (security.indexOf("WPA") >= 0 || security.indexOf("WEP") >= 0)
        if (strength >= 75) return isSecured ? "󰤪" : "󰤨"
        if (strength >= 50) return isSecured ? "󰤧" : "󰤥"
        if (strength >= 25) return isSecured ? "󰤤" : "󰤢"
        return isSecured ? "󰤡" : "󰤟"
    }

    function openFrom(anchorItem, relativeItem) {
        var topParent = null
        if (anchorItem) {
            var p = anchorItem.parent
            if (p) {
                topParent = p
                while (topParent.parent) {
                    topParent = topParent.parent
                }
            }
        }

        if (topParent) {
            menu.parent = topParent
        }

        menu.open()
        Qt.callLater(function() {
            const p = menu.parent ? menu.parent : (relativeItem || anchorItem)
            if (!p) return

            const anchor = anchorItem.mapToItem(p, anchorItem.width/2, anchorItem.height)
            menu.x = Math.round(anchor.x - menu.width/2)
            menu.y = Math.round(anchor.y + 8)

            if (p.width) {
                menu.x = Math.max(6, Math.min(menu.x, Math.round(p.width - menu.width - 6)))
            }
        })
    }

    function refresh() {
        wifiStateProc.running = false
        wifiStateProc.running = true
        listProc.running = false
        listProc.running = true
    }

    function connectTo(ssid) {
        statusText = "Connecting to " + ssid + "…"
        connectProc.command = ["bash", "-lc", "nmcli dev wifi connect \"" + ssid + "\""]
        connectProc.running = false
        connectProc.running = true
    }

    function toggleWifi() {
        var nextState = menu.wifiEnabled ? "off" : "on"
        toggleProc.command = ["bash", "-lc", "nmcli radio wifi " + nextState]
        toggleProc.running = false
        toggleProc.running = true
    }

    // Wi-Fi Radio general state
    Process {
        id: wifiStateProc
        command: ["bash", "-lc", "nmcli -t -f WIFI general 2>/dev/null || echo enabled"]
        stdout: StdioCollector {
            onStreamFinished: {
                const s = text.trim().toLowerCase()
                menu.wifiEnabled = (s === "enabled")
            }
        }
    }

    // List networks and parse unique SSIDs
    Process {
        id: listProc
        command: ["bash", "-lc", "nmcli -t -f SSID,SIGNAL,ACTIVE,SECURITY dev wifi | awk -F: '$1 == \"\" { next } { ssid=$1; sig=$2; act=$3; sec=$4; if (!(ssid in highest) || sig > highest[ssid]) { highest[ssid] = sig; active[ssid] = act; security[ssid] = sec } } END { for (ssid in highest) { print ssid \"\\t\" highest[ssid] \"\\t\" active[ssid] \"\\t\" security[ssid] } }'"]

        stdout: StdioCollector {
            onStreamFinished: {
                wifiModel.clear()
                const lines = text.split("\n").filter(l => l.trim().length > 0)
                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split("\t")
                    const ssid = (parts[0] || "").trim()
                    const signal = parseInt((parts[1] || "0").trim(), 10)
                    const active = (parts[2] || "no").trim() === "yes"
                    const security = (parts[3] || "").trim()

                    if (!ssid) continue
                    wifiModel.append({ ssid, signal, active, security })
                }
                if (wifiModel.count === 0) statusText = "No networks found."
                else statusText = ""
            }
        }
    }

    // Connect process
    Process {
        id: connectProc
        onExited: {
            menu.refresh()
        }
    }

    // Toggle process
    Process {
        id: toggleProc
        onExited: {
            menu.refresh()
        }
    }

    onOpened: refresh()

    background: Rectangle {
        radius: 16
        color: menu.bg
        border.width: 1
        border.color: menu.border
    }

    contentItem: ColumnLayout {
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Wi-Fi Networks"
                color: menu.text
                font.pixelSize: 14
                font.weight: 700
            }

            Item { Layout.fillWidth: true }

            // Power switch
            Rectangle {
                width: 42
                height: 22
                radius: 11
                color: menu.wifiEnabled ? menu.accent : "#313244"
                border.width: 1
                border.color: menu.border
                Layout.alignment: Qt.AlignVCenter

                Behavior on color { ColorAnimation { duration: 120 } }

                Rectangle {
                    id: toggleKnob
                    width: 16
                    height: 16
                    radius: 8
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                    x: menu.wifiEnabled ? parent.width - width - 3 : 3
                    Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: menu.toggleWifi()
                }
            }

            Rectangle {
                width: 26
                height: 26
                radius: 10
                color: refreshMouse.pressed ? "#44ffffff" : (refreshMouse.containsMouse ? "#22ffffff" : "transparent")
                border.width: 1
                border.color: refreshMouse.containsMouse ? "#45475a" : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "󰑓"
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 14
                    color: menu.text
                    opacity: 0.95
                }

                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: menu.refresh()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            radius: 1
            color: menu.border
            opacity: 0.9
        }

        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: 240
            clip: true
            contentWidth: width
            contentHeight: listCol.implicitHeight

            Column {
                id: listCol
                width: parent.width
                spacing: 6

                Repeater {
                    model: wifiModel

                    Rectangle {
                        width: parent.width
                        height: 44
                        radius: 14
                        color: rowMouse.pressed ? "#44ffffff" : (rowMouse.containsMouse ? "#22ffffff" : "transparent")
                        border.width: 1
                        border.color: rowMouse.containsMouse ? "#45475a" : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Text {
                                text: menu.wifiIcon(model.signal, model.security)
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 18
                                color: model.active ? menu.accent : menu.text
                                Layout.alignment: Qt.AlignVCenter
                                opacity: model.active ? 1.0 : 0.9
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: -2

                                Text {
                                    text: model.ssid
                                    color: menu.text
                                    font.pixelSize: 13
                                    font.weight: model.active ? 800 : 600
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: model.active ? "Connected" : "Signal: " + model.signal + "%"
                                    color: menu.subtext
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Text {
                                text: model.active ? "Disconnect" : "Connect"
                                color: menu.subtext
                                font.pixelSize: 11
                                opacity: 0.85
                                Layout.alignment: Qt.AlignVCenter
                                visible: !model.active
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!model.active) {
                                    menu.connectTo(model.ssid)
                                }
                            }
                        }
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: menu.statusText
            color: menu.subtext
            font.pixelSize: 11
            opacity: 0.95
            visible: menu.statusText.length > 0
            elide: Text.ElideRight
        }
    }
}

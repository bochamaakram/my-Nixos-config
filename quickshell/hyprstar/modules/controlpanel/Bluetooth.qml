import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.services as Services
import qs.theme as Theme

Item {
    id: root
    implicitHeight: 60
    Layout.fillWidth: true

    signal activated()
    property string fallbackTitle: "Bluetooth"

    readonly property bool isConnected: Services.Bluetooth.connected
    readonly property bool isPowered: Services.Bluetooth.powered

    // Direct bindings to Theme properties - simple on/off only
    readonly property color bgColor:       isPowered ? Theme.Theme.accent : Theme.Theme.gridBttn_off_bg
    readonly property color borderColor:   Theme.Theme.border
    readonly property color iconColor:     isPowered ? Theme.Theme.gridBttn_on_ttl : Theme.Theme.gridBttn_off_ttl
    readonly property color titleColor:    isPowered ? Theme.Theme.gridBttn_on_ttl : Theme.Theme.gridBttn_off_ttl
    readonly property color subtitleColor: isPowered ? Theme.Theme.gridBttn_on_subt : Theme.Theme.gridBttn_off_subt

    function btIcon(powered, connected) {
        if (!powered) return "󰂲"     // off
        if (connected) return "󰂱"    // connected
        return "󰂯"                   // on (not connected)
    }

    // Toggle Bluetooth power
    Process {
        id: btPowerProc
        command: ["bash", "-lc", "dbus-send --system --dest=org.bluez --print-reply /org/bluez/hci0 org.freedesktop.DBus.Properties.Set string:org.bluez.Adapter1 string:Powered variant:boolean:" + (root.isPowered ? "false" : "true")]
    }

    Loader {
        id: bluetoothMenuLoader
        active: false
        source: Qt.resolvedUrl("BluetoothMenu.qml")
    }

    function toggleBluetoothMenu() {
        bluetoothMenuLoader.active = true
        const m = bluetoothMenuLoader.item
        if (m && m.openFrom) {
            m.openFrom(card, root)
        }
    }

    function subtitleText() {
        if (!isPowered) return "Off"
        return isConnected ? "Connected" : "On"
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16
        color: bgColor
        border.width: 1
        border.color: borderColor

        property bool hovered: false
        property bool pressed: false
        scale: pressed ? 0.98 : (hovered ? 1.01 : 1.0)

        Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text {
                text: btIcon(isPowered, isConnected)
                color: iconColor
                font.pixelSize: 18
                font.family: "Hack Nerd Font"
                opacity: isPowered ? 1.0 : 0.85
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: -3
                Layout.alignment: Qt.AlignVCenter

                Text {
                    Layout.fillWidth: true
                    text: isConnected ? Services.Bluetooth.deviceName : root.fallbackTitle
                    color: titleColor
                    font.pixelSize: 14
                    font.weight: 600
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: subtitleText()
                    color: subtitleColor
                    opacity: 0.9
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                id: manageBtn
                width: 26
                height: 26
                radius: 8
                color: "transparent"
                border.width: 1
                border.color: "transparent"
                Layout.alignment: Qt.AlignVCenter

                property bool hovered: false
                property bool pressed: false

                states: [
                    State {
                        name: "hovered"
                        when: manageBtn.hovered && !manageBtn.pressed
                        PropertyChanges { target: manageBtn; color: "#22ffffff"; border.color: "#33ffffff" }
                    },
                    State {
                        name: "pressed"
                        when: manageBtn.pressed
                        PropertyChanges { target: manageBtn; color: "#44ffffff"; border.color: "#55ffffff" }
                    }
                ]

                Behavior on color { ColorAnimation { duration: 110 } }
                Behavior on border.color { ColorAnimation { duration: 110 } }

                Text {
                    anchors.centerIn: parent
                    text: "󰅂"
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 14
                    color: titleColor
                    opacity: isPowered ? 0.9 : 0.5
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: manageBtn.hovered = true
                    onExited: { manageBtn.hovered = false; manageBtn.pressed = false }
                    onPressed: manageBtn.pressed = true
                    onReleased: manageBtn.pressed = false
                    onClicked: {
                        root.toggleBluetoothMenu()
                        root.activated()
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onEntered: card.hovered = true
            onExited: { card.hovered = false; card.pressed = false }
            onPressed: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    card.pressed = true
                }
            }
            onReleased: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    card.pressed = false
                }
            }
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    // Left click: Open devices list menu
                    root.toggleBluetoothMenu()
                } else if (mouse.button === Qt.RightButton) {
                    // Right click: Toggle bluetooth power
                    btPowerProc.running = false
                    btPowerProc.running = true
                }
            }
        }
    }
}
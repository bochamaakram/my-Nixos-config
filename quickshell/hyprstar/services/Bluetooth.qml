pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool powered: false
    property bool connected: false
    property string deviceName: ""   // connected device name (first one), or ""

    function refresh() {
        poweredProc.running = false
        poweredProc.running = true

        connectedDevProc.running = false
        connectedDevProc.running = true
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // Powered: yes/no
    Process {
        id: poweredProc
        command: ["bash", "-lc", "dbus-send --system --dest=org.bluez --print-reply /org/bluez/hci0 org.freedesktop.DBus.Properties.Get string:org.bluez.Adapter1 string:Powered 2>/dev/null | grep -q 'boolean true' && echo 'true' || echo 'false'"]

        stdout: StdioCollector {
            onStreamFinished: {
                var v = text.trim().toLowerCase()
                root.powered = (v === "yes" || v === "true" || v === "on")
                if (!root.powered) {
                    root.connected = false
                    root.deviceName = ""
                }
            }
        }
    }

    // First connected device:
    Process {
        id: connectedDevProc
        command: ["bash", "-lc", "dbus-send --system --dest=org.bluez --print-reply / org.freedesktop.DBus.ObjectManager.GetManagedObjects | awk '/object path/ { name = \"\"; conn = \"false\" } /string \"Name\"/ { getline; name = $0; sub(/.*string \"/, \"\", name); sub(/\"$/, \"\", name); if (conn == \"true\" && name != \"\") { print name; exit } } /string \"Connected\"/ { getline; conn = $3; if (conn == \"true\" && name != \"\") { print name; exit } }'"]

        stdout: StdioCollector {
            onStreamFinished: {
                var name = text.trim()
                if (!root.powered || name.length === 0) {
                    root.connected = false
                    root.deviceName = ""
                } else {
                    root.deviceName = name
                    root.connected = true
                }
            }
        }
    }
}

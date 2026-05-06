//@pragma UseQApplication

import QtQuick
import Quickshell
import qs.bar
import qs.bar.placeholders
import qs.services
import "modules/lockscreen" as Locks
import "modules/menus"
import "notifications" as Notifs

ShellRoot {
    id: root

    ThemeMenu { id: themeMenu }

    Variants {
        model: Quickshell.screens
        Wallpaper {
            required property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens
        Bar {
            required property var modelData
            targetScreen: modelData
        }
    }

    Variants {
        model: Quickshell.screens
        Mask {
            required property var modelData
            targetScreen: modelData
        }
    }

    Locks.Lockscreen { id: lockscreen }
    AppLauncher {}
    Notifs.NotificationPopup {}
}

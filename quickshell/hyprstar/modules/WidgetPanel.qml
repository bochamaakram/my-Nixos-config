// modules/WidgetPanel.qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.modules.datetimepanel
import qs.theme as Theme

PanelWindow {
    id: panel
    visible: false
    color: "transparent"
    exclusiveZone: 0
    focusable: true
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    LazyLoader {
        id: backdropLoader
        activeAsync: panel.visible

        PanelWindow {
            color: "transparent"
            visible: true
            exclusiveZone: -1
            anchors { top: true; bottom: true; left: true; right: true }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                hoverEnabled: true
                onPressed: panel.visible = false
            }
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [ panel ]
        active: panel.visible
        onCleared: panel.visible = false
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: panel.visible = false
    }

    // expansion state (only relevant on page 0)
    property bool remindersExpanded: false
    property bool weatherExpanded: false

    function clamp01(v) { return Math.max(0, Math.min(1, v)) }
    function lerp(a, b, t) { return a + (b - a) * t }

    onVisibleChanged: {
        if (visible) {
            remindersExpanded = false
            weatherExpanded = false
        }
    }

    onRemindersExpandedChanged: if (remindersExpanded) weatherExpanded = false
    onWeatherExpandedChanged: if (weatherExpanded) remindersExpanded = false

    // --- shadow ---
    property int shadowPad: 10
    property real shadowOpacity: 0.28
    property real shadowBlur: 0.55
    property int shadowOffsetY: 6

    // size
    property int contentW: 600
    property int contentH: 295
    implicitWidth: contentW + shadowPad * 2
    implicitHeight: contentH + shadowPad * 2

    anchors { top: true; left: true }
    margins { top: 6 - shadowPad; left: 6 - shadowPad }

    // ===== padding knobs =====
    // overall inner padding for the whole content area
    property int contentPadding: 12

    Item {
        id: wrap
        anchors.fill: parent
        anchors.margins: panel.shadowPad

        Rectangle {
            anchors.fill: parent
            radius: 16
            antialiasing: true
            color: Theme.Theme.bg

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowOpacity: panel.shadowOpacity
                shadowVerticalOffset: panel.shadowOffsetY
                shadowBlur: panel.shadowBlur
            }
        }

        Rectangle {
            id: clipCard
            anchors.fill: parent
            radius: 16
            color: "transparent"
            clip: true
            antialiasing: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: panel.contentPadding
                spacing: 12


                // =========================
                // PAGES (slide)
                // =========================
                Item {
                    id: pageViewport
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Row {
                        id: pageRow
                        width: pageViewport.width
                        height: pageViewport.height
                        spacing: 0

                        x: 0

                        // -------- Page 0: Dashboard --------
                        Item {
                            id: dashboardPage
                            width: pageViewport.width
                            height: pageViewport.height

                            Item {
                                id: overlaySurface
                                anchors.fill: parent
                                visible: panel.remindersExpanded
                                z: 9999

                                Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0 }

                                MouseArea {
                                    anchors.fill: parent
                                    onPressed: (m) => { m.accepted = true }
                                    onClicked: (m) => { m.accepted = true }
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                spacing: 12

                                ColumnLayout {
                                    Layout.preferredWidth: 280
                                    Layout.minimumWidth: 280
                                    Layout.maximumWidth: 280
                                    Layout.fillHeight: true

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true
                                        opacity: panel.remindersExpanded ? 0.0 : 1.0
                                        enabled: !panel.remindersExpanded
                                        Behavior on opacity { NumberAnimation { duration: 140 } }

                                        Calendar { anchors.fill: parent }
                                    }
                                }

                                Item {
                                    id: rightRegion
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.minimumWidth: 180

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 12

                                        Item {
                                            id: weatherSlot
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            Layout.minimumHeight: 65
                                            opacity: panel.remindersExpanded ? 0.0 : 1.0
                                            enabled: !panel.remindersExpanded
                                            Behavior on opacity { NumberAnimation { duration: 140 } }
                                        }

                                        Item {
                                            id: remindersSlot
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            Layout.minimumHeight: 90
                                        }
                                    }
                                }
                            }

                            // ===== Weather Host =====
                            Item {
                                id: weatherHost
                                z: 9500

                                Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                                Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                                Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                                Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                                Weather {
                                    anchors.fill: parent
                                    iconDir: "../assets/weather"

                                    expanded: panel.weatherExpanded
                                    onRequestExpand: panel.weatherExpanded = true
                                    onRequestCollapse: panel.weatherExpanded = false

                                    active: panel.visible && !panel.remindersExpanded
                                }
                            }

                            // ===== Reminders Host =====
                            Item {
                                id: remindersHost
                                z: 10000

                                opacity: panel.weatherExpanded ? 0.0 : 1.0
                                enabled: !panel.weatherExpanded
                                Behavior on opacity { NumberAnimation { duration: 140 } }

                                Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                                Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                                Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                                Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                                Reminders {
                                    anchors.fill: parent
                                    expanded: panel.remindersExpanded
                                    onRequestExpand: panel.remindersExpanded = true
                                    onRequestCollapse: panel.remindersExpanded = false
                                }
                            }

                            StateGroup {
                                states: [
                                    State {
                                        name: "remindersNormal"
                                        when: !panel.remindersExpanded
                                        ParentChange { target: remindersHost; parent: remindersSlot }
                                        PropertyChanges { target: remindersHost; x: 0; y: 0; width: remindersSlot.width; height: remindersSlot.height }
                                    },
                                    State {
                                        name: "remindersExpanded"
                                        when: panel.remindersExpanded
                                        ParentChange { target: remindersHost; parent: overlaySurface }
                                        PropertyChanges { target: remindersHost; x: 0; y: 0; width: overlaySurface.width; height: overlaySurface.height }
                                    }
                                ]
                            }

                            StateGroup {
                                states: [
                                    State {
                                        name: "weatherNormal"
                                        when: !panel.weatherExpanded
                                        ParentChange { target: weatherHost; parent: weatherSlot }
                                        PropertyChanges { target: weatherHost; x: 0; y: 0; width: weatherSlot.width; height: weatherSlot.height }
                                    },
                                    State {
                                        name: "weatherExpanded"
                                        when: panel.weatherExpanded
                                        ParentChange { target: weatherHost; parent: rightRegion }
                                        PropertyChanges { target: weatherHost; x: 0; y: 0; width: rightRegion.width; height: rightRegion.height }
                                    }
                                ]
                            }
                        }
                    }
                }
            }
        }
    }
}

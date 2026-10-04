import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick

import qs // Theme
import qs.Templates
import qs.DataProviders

PanelWindow {
    id: window
    visible: false
    color: "transparent"

    focusable: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    margins {
        left: Theme.barWidth
    }

    Rectangle {
        id: windowBG
        // color: "#44000000"
        color: "transparent"
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        Rectangle {
            color: "transparent"
            id: root
            implicitWidth: 750
            implicitHeight: 300

            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            // added this here because PanelWindows isn't an Item
            state: "CLOSED"
            states: [
                State {
                    name: "CLOSED"
                    PropertyChanges { target: window; visible: false }
                },
                State {
                    name: "OPENED"
                }
            ]

            transitions : [
                Transition {
                    from: "CLOSED"
                    to: "OPENED"

                    SequentialAnimation {
                        PropertyAction {
                            target: window
                            property: "visible"
                            value: true
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: searchbar
                                properties: "height"
                                from: 0
                                to: 45
                                duration: 100
                                easing: Easing.InQuad
                            }
                            NumberAnimation {
                                target: root
                                properties: "opacity"
                                from: 0
                                to: 1
                                duration: 50
                                easing: Easing.InExpo
                            }
                            NumberAnimation {
                                target: listview
                                properties: "height"
                                from: 0
                                to: root.height - searchbar.height
                                duration: 100
                            }
                        }
                    }
                },
                Transition {
                    from: "OPENED"
                    to: "CLOSED"
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: searchbar
                                properties: "height"
                                from: 45
                                to: 0
                                duration: 150
                                easing: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: listview
                                properties: "height"
                                from: root.height - searchbar.height
                                to: 0
                                duration: 100
                            }
                            NumberAnimation {
                                target: root
                                properties: "opacity"
                                from: 1
                                to: 0
                                duration: 100
                            }
                        }
                        PropertyAction {
                            target: window
                            property: "visible"
                            value: false
                        }
                    }
                }
            ]

            /*
             *  Far back shadow
             */
            RectangularShadow {
                anchors.fill: searchbar
                blur: 0
                spread: 1
                offset {
                    x: 12
                    y: 12
                }

                color: Theme.fg1
            }

            /*
             *  "View" of the Launcher
             */

            ListView {
                id: listview
                anchors {
                    top: searchbar.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                topMargin: 6
                leftMargin: 6

                clip: true
                reuseItems: true
                highlightFollowsCurrentItem: true

                height: root.height - searchbar.height
                width: root.width - 40
                orientation: Qt.Vertical
                verticalLayoutDirection: ListView.TopToBottom

                function reset() {
                    handler.toggle()
                    searchbar.clear()
                    listview.model = LauncherData.entries
                }

                model: LauncherData.entries
                delegate: LauncherItem {}
            }

            /*
             *  Searchfield + main shadow
             */
            
            RectangularShadow {
                anchors.fill: searchbar
                blur: 0
                spread: 1
                offset {
                    x: 6
                    y: 6
                }

                color: Theme.fgBlue
            }

            TextField {
                id: searchbar
                implicitHeight: 45
                implicitWidth: parent.width
                anchors {
                    top: parent.top
                    left: parent.left
                }

                placeholderText: "search"
                hoverEnabled: true

                font {
                    family: Theme.fontFamily
                    pointSize: Theme.fontLarge
                }

                background : Rectangle {
                    color: Theme.bg1
                    border {
                        color: searchbar.Theme.bgBlue
                        width: 3
                    }
                }

                /*
                 *  Keybinds/Actions
                 */
                Keys.onEscapePressed: {
                    listview.reset()
                }

                Keys.onUpPressed: {
                    listview.decrementCurrentIndex()
                }

                Keys.onDownPressed: {
                    listview.incrementCurrentIndex()
                }

                onAccepted: {
                    var entry = listview.currentItem
                    LauncherData.launch(entry.modelData)
                    listview.reset()
                }

                onTextEdited: {
                    listview.model = LauncherData.query(this.text)
                }
            }

            /*
             *  Registered cmd for compositor
             */
            IpcHandler {
                id: handler
                target: "launcher"
                function toggle() : void {
                    // window.visible = !window.visible;
                    root.state = root.state === "CLOSED" ? "OPENED" : "CLOSED"
                    if (root.state === "OPENED") {
                        searchbar.forceActiveFocus()
                    }
                }
            }
        }

    }

}

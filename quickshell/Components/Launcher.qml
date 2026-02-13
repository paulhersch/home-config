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
    Rectangle {
        id: windowBG
        color: "#44000000"
        anchors.fill: parent

        Rectangle {
            color: "transparent"
            id: root
            implicitWidth: 750
            implicitHeight: 500

            anchors {
                centerIn: parent
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
                                properties: "width"
                                from: 0
                                to: root.width
                                duration: 50
                            }
                            NumberAnimation {
                                target: listview
                                properties: "opacity"
                                from: 0
                                to: 1
                                duration: 100
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
                                properties: "width"
                                from: root.width
                                to: 0
                                duration: 50
                            }
                            NumberAnimation {
                                target: listview
                                properties: "height"
                                from: root.height - searchbar.height
                                to: 0
                                duration: 100
                            }
                            NumberAnimation {
                                target: listview
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
             *  "View" of the Launcher
             */
            ListView {
                id: listview
                anchors {
                    top: searchbar.bottom
                    horizontalCenter: parent.horizontalCenter
                }

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

            RectangularShadow {
                anchors.fill: searchbar
                blur: 20
                spread: -2

                color: Theme.fgBlue
            }
            /*
             *  Searchfield
             */
            TextField {
                id: searchbar
                implicitHeight: 45
                implicitWidth: parent.width
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }

                placeholderText: "search"
                hoverEnabled: true

                font {
                    family: Theme.fontFamily
                    pointSize: Theme.fontLarge
                }

                background : Rectangle {
                    color: Theme.bgBlue
                    border {
                        color: searchbar.Theme.fg1
                        width: 1
                    }

                    radius: 10

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

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick

import qs // Theme
import qs.Templates
import qs.DataProviders

PanelWindow {
    required property var anchorWindow

    id: window
    visible: false
    color: "transparent"

    implicitWidth: 700
    implicitHeight: 450
    focusable: true

    margins {
        top: 20
    }
    anchors {
        top: true
    }

    Rectangle {
        color: "transparent"

        anchors {
            fill:parent
        }

        /*
         *  Searchfield
         */
        TextField {
            id: searchbar
            implicitWidth: window.implicitWidth
            implicitHeight: 45
            anchors {
                top: parent.top
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
         *  "View" of the Launcher
         */
        Rectangle {
            id: viewBg
            
            color: "transparent"
            height: window.height - searchbar.height
            width: window.width - 20 // margins

            anchors {
                top: searchbar.bottom
                horizontalCenter: parent.horizontalCenter
            }

            ListView {
                id: listview
                clip: true
                reuseItems: true
                highlightFollowsCurrentItem: true

                anchors.fill : parent

                orientation: Qt.Vertical
                verticalLayoutDirection: ListView.TopToBottom

                function reset() {
                    window.visible = false
                    searchbar.clear()
                    listview.model = LauncherData.entries
                }

                model: LauncherData.entries
                delegate: LauncherItem {}
            }
        }

        /*
         *  Registered cmd for niri/sway
         */
        IpcHandler {
            target: "launcher"
            function toggle() : void {
                window.visible = !window.visible;
            }
        }
    }
}

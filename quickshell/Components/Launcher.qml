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
            fill: parent
            margins: 10
        }

        /*
         *  "View" of the Launcher
         */
        Rectangle {
            id: viewBg
            
            color: "transparent"
            height: window.height - searchbar.height
            width: window.width - 40 // margins

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
            implicitWidth: parent.width
            implicitHeight: 45
            anchors {
                top: parent.top
                leftMargin: 10
                rightMargin: 10
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
         *  Registered cmd compositor
         */
        IpcHandler {
            target: "launcher"
            function toggle() : void {
                window.visible = !window.visible;
            }
        }
    }
}

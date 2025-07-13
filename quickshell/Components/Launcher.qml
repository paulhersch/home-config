import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick

import "root:/" // Theme
import "root:/Templates"
import "root:/Components/DataProviders"

PanelWindow {
    required property var anchorWindow

    id: window
    visible: false

    implicitWidth: 700
    implicitHeight: 300
    focusable: true

    anchors {
        top: true
    }

    TextField {
        id: searchbar
        implicitWidth: window.implicitWidth
        implicitHeight: Theme.fontLarge * 2
        anchors {
            top: parent.top
        }
        placeholderText: "search"
        hoverEnabled: true

        font {
            family: Theme.fontFamily
            pixelSize: Theme.fontLarge
        }

        background : Rectangle {
            color: Theme.bgBlue
            border {
                color: searchbar.Theme.fg1
                width: 1
            }
        }

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

    ListView {
        id: listview
        height: window.height - searchbar.height
        width: window.width
        clip: true
        reuseItems: true
        highlightFollowsCurrentItem: true
        anchors {
            top: searchbar.bottom
        }
        orientation: Qt.Vertical
        verticalLayoutDirection: ListView.TopToBottom
        spacing: 5

        function reset() {
            window.visible = false
            searchbar.clear()
            listview.model = LauncherData.entries
        }

        model: LauncherData.entries
        delegate: LauncherItem {}
    }

    IpcHandler {
        target: "launcher"
        function toggle() : void {
            window.visible = !window.visible;
        }
    }
}

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "root:/"

MouseArea {
    id: root

    required property var modelData
    required property var socket

    height: bg.height
    width: bg.width
    preventStealing: true

    Rectangle {
        id: bg
        color: root.pressed ? Theme.fgRed : (modelData.is_focused ? Theme.bgRed : "transparent")
        width: icon.width + 5
        height: icon.height + 5
    }

    IconImage {
        anchors {
            centerIn: parent
        }
        id: icon
        source: {
            // handle exceptions for certain IDs
            let name = root.modelData.app_id
            switch (name) {
                case "Signal":
                    name = "org.signal.Signal"
                    break;
                case "Spotify":
                    name = "spotify"
                    break;
                default:
                    break;
            }
            return Quickshell.iconPath(name)
        }
        implicitSize: 28
    }

    onClicked: event => {
        root.socket.focusWindow(root.modelData.id)
    }
}


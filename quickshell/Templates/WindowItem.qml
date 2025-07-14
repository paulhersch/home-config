import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

import qs

MouseArea {
    id: root

    required property var modelData
    required property var socket

    height: icon.height
    width: icon.width

    IconImage {
        anchors {
            centerIn: parent
        }
        id: icon
        source: {
            // handle exceptions for certain IDs
            Helpers.handledIcons(root.modelData.app_id)
        }
        implicitSize: 28
    }

    onClicked: event => {
        root.socket.focusWindow(root.modelData.id)
    }
}


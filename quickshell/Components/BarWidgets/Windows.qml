import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.I3
import Quickshell.Widgets

import qs
import qs.Templates
import qs.DataProviders

Item {
    id: root

    // moving background
    Rectangle {
        id: bg
        
        anchors {
            verticalCenter: parent.verticalCenter
            left: root.left
            leftMargin: Niri.focusedWindowIndex * (layout.height + layout.spacing)
        }
        color: Theme.bgBlue
        width: layout.height + 8
        height: layout.height + 8
        radius: 10

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: 100
            }
        }
    }

    // the actual windows
    RowLayout {
        anchors {
            verticalCenter: parent.verticalCenter
            left: root.left
            leftMargin: (bg.width - height)/2
        }

        id: layout
        spacing: 10
        uniformCellSizes: false
        Layout.alignment: Qt.AlignCenter

        Repeater {
            // Only create Windows if Niri exists
            model: (I3.socketPath != "") ? ListModel({}) : Niri.windows
            delegate: WindowItem {
                socket: Niri
            }
        }
    }
}

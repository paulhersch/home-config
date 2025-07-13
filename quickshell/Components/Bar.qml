import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls

import "root:/Components/BarWidgets" as Widgets
import "root:/"

PanelWindow {
    id: bar
    color: Theme.bg1 
    focusable: true

    anchors {
        bottom: true
        left: true
        right: true
    }

    implicitHeight: 35

    /*
     *  Popups
     */

    Launcher {
        anchorWindow: bar
    }

    /*
     *  Widgets
     */

    Widgets.Workspaces {
        id: workspaces
        height: parent.height
        anchors {
            leftMargin: 10
            left: parent.left
        }
    }

    Widgets.Windows {
        id: windows
        height: parent.height
        anchors {
            leftMargin: 20
            left: workspaces.right
        }
    }

    Widgets.Battery {
        id: battery
        width: parent.width
        height: parent.height
        orientation: Qt.Horizontal

        anchors {
            centerIn: parent
        }
    }

    Widgets.Clock {
        id: clock
        anchors {
            rightMargin: 10
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
    }

    Widgets.Tray {
        id: tray
        height: parent.height
        // orientation: Qt.Horizontal

        anchors {
            rightMargin: 15
            right: clock.left
            verticalCenter: parent.verticalCenter
        }
    }
}

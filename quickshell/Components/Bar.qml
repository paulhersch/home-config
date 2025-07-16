import Quickshell
import Quickshell.Io
import Quickshell.I3
import QtQuick
import QtQuick.Controls

import qs.Components.BarWidgets
import qs.DataProviders
import qs

PanelWindow {
    id: bar
    color: Theme.bg1 
    focusable: true

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 40

    /*
     *  Popups
     */

    Launcher {
        anchorWindow: bar
    }

    /*
     *  Widgets
     */

    Workspaces {
        id: workspaces
        height: parent.height
        anchors {
            leftMargin: 10
            left: parent.left
        }
    }


    Windows {
        height: parent.height
        anchors {
            leftMargin: 20
            left: workspaces.right
            verticalCenter: parent.verticalCenter
        }
    }

    Battery {
        id: battery
        height: parent.height
        orientation: Qt.Horizontal

        anchors {
            centerIn: parent
        }
    }

    Clock {
        id: clock
        anchors {
            rightMargin: 10
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
    }

    Tray {
        id: tray
        height: parent.height
        // orientation: Qt.Horizontal

        anchors {
            rightMargin: 30
            right: clock.left
            verticalCenter: parent.verticalCenter
        }
    }
    
    Mpris {
        id: mpris
        height: parent.height

        anchors {
            right: tray.left
            rightMargin: 30
            verticalCenter: parent.verticalCenter
        }
    }
}

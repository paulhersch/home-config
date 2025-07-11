import Quickshell
import Quickshell.Io
import QtQuick

import "BarWidgets" as Widgets

Scope {
    PanelWindow {

        id: bar

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 30

        Widgets.Workspaces {
            height: parent.height
            width: parent.width
            orientation: Qt.Horizontal
            anchors {
                leftMargin: 10
                left: parent.left
                verticalCenter: parent.verticalCenter
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
            // width: 500
            // orientation: Qt.Horizontal

            anchors {
                rightMargin: 15
                right: clock.left
                verticalCenter: parent.verticalCenter
            }
        }
    }
}

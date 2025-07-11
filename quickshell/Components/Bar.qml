import Quickshell
import Quickshell.Io
import QtQuick

import "BarWidgets" as Widgets

Scope {
    PanelWindow {

        id: bar

        anchors {
            bottom: true
            left: true
            right: true
        }

        implicitHeight: 40

        Widgets.Workspaces {
            height: parent.height
            width: 200
            orientation: Qt.Horizontal
            anchors {
                leftMargin: 10
                left: parent.left
                verticalCenter: parent.verticalCenter
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

        Widgets.Battery {
            anchors {
                rightMargin: 10
                right: clock.left
                verticalCenter: parent.verticalCenter
            }
        }
    }
}

import Quickshell
import Quickshell.Io
import Quickshell.I3
import QtQuick
import QtQuick.Controls

import qs.Components.BarWidgets
import qs.DataProviders
import qs

Variants {
    model: Quickshell.screens

    PanelWindow {
        required property ShellScreen modelData // screen

        id: bar
        color: Theme.bg1 
        focusable: true
        screen: modelData

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: Theme.barHeight

        /*
         *  Popups
         */


        /*
         *  Widgets
         */

        Workspaces {
            id: workspaces
            height: parent.height
            anchors {
                // horizontalCenter: parent.horizontalCenter
                leftMargin: 10
                left: parent.left
            }
        }

        NotificationPill {
            id: notifs
            width: 400

            anchors {
                centerIn: parent
            }
        }

        // Windows {
        //     height: parent.height
        //     anchors {
        //         leftMargin: 20
        //         left: parent.left
        //         verticalCenter: parent.verticalCenter
        //     }
        // }

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
                right: clock.left
                rightMargin: 20
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
}

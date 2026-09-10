import Quickshell
import Quickshell.Io
import Quickshell.I3
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Components.BarWidgets
import qs.DataProviders
import qs

Variants {
    model: Quickshell.screens

    PanelWindow {
        required property ShellScreen modelData // screen

        id: bar
        // color: Theme.bg1 //"#00000000"
        focusable: true
        screen: modelData

        anchors {
            top: true
            left: true
            bottom: true
        }

        implicitWidth: Theme.barWidth

        Image { // fake translucency by projecting part of the bgimage on the bar hehe
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: bar.screen.width
            
            source: Theme.backgroundImage
            fillMode: Image.PreserveAspectCrop
        }

        /*
         *  Widgets
         */
        // ColumnLayout {
            // width : parent.width
            Workspaces {
                id: workspaces
                width: parent.width
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    topMargin: 10
                    top: parent.top
                }
            }

            // NotificationPill {
            //     id: notifs
            //     width: 400
            //
            //     anchors {
            //         centerIn: parent
            //     }
            // }

            // Windows {
            //     height: parent.height
            //     anchors {
            //         leftMargin: 10
            //         left: workspaces.right
            //         verticalCenter: parent.verticalCenter
            //     }
            // }

            Battery {
                id: battery
                width: parent.width

                anchors {
                    bottom: parent.bottom
                    bottomMargin: 10
                    // margin, bat item has to do that by itself
                }
            }
            
            Clock {
                id: clock
                width : parent.width
                anchors {
                    verticalCenter: parent.verticalCenter
                    left : parent.left
                }
            }

            Tray {
                id: tray
                width: parent.width

                anchors {
                    bottom: battery.top
                    bottomMargin: 10
                    horizontalCenter: parent.horizontalCenter
                }
            }
            //
            // KbdLayouts {
            //     id: kbd
            //     height: parent.height - 8;
            //
            //     anchors {
            //         right: clock.left
            //         rightMargin: (I3.socketPath == "") ? 15 : 0
            //         verticalCenter: parent.verticalCenter
            //     }
            // }

            Mpris {
                id: mpris
                width: parent.width

                anchors {
                    bottom: tray.top
                    bottomMargin: 10
                    horizontalCenter: parent.horizontalCenter
                }
            }
        // }
    }
}

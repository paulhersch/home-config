import Quickshell
import Quickshell.I3
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


import "root:/Components/DataProviders" as Providers
import "root:/"

RowLayout {
    height: parent.height
    spacing: 10

    // Rectangle {
    //     width: parent.width
    //     height: parent.height
    //     color: "black"
    // }

    Repeater {
        // check if i3 is alive, if not use niri module as source
        model: (I3.socketPath != "") ? I3.workspaces.values : Providers.Niri.workspaces

        delegate: Rectangle {
            id: wrapper
            // important variables
            required property bool focused
            required property bool active
            required property int number

            Rectangle {
                id: inner

                width: focused ? 30 : 20
                height: parent.height
                color: focused ? Theme.bgBlue : Theme.bg2
                radius: 0

                anchors {
                    centerIn: parent
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 100
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }
            }
            color: Theme.bg1
            width: 20
            height: 15
        }
    }
}

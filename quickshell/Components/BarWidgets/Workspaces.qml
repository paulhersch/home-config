import Quickshell
import Quickshell.I3
import Quickshell.Widgets
import QtQuick

import "../DataProviders" as Providers

ListView {

    anchors {
        verticalCenter: parent.verticalCenter
    }

    Component {
        id: wsComp
        Rectangle {
            id: wrapper
            // important variables
            required property bool focused
            required property bool active
            required property int number

            anchors {
                verticalCenter: parent.verticalCenter
            }

            width: text.width + 20
            height: text.height + 5
            color: focused ? "#aae" : "#fff"

            Text {
                id: text
                // actual stuff happening here
                text: wrapper.number
                color: focused ? "blue" : "black"
                anchors {
                    centerIn: parent
                }

                font {
                    family: "Aporetic With Fallback"
                    pixelSize: 14
                }
            }
        }
    }

    // check if i3 is alive, if not use niri module as source
    model: (I3.socketPath != "") ? I3.workspaces.values : Providers.Niri.workspaces
    delegate: wsComp
}



import Quickshell
import Quickshell.I3
// import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.DataProviders
import qs.Templates
import qs

ColumnLayout {
    spacing: 10

    Repeater {
        // check if i3 is alive, if not use niri module as source
        model: (I3.socketPath != "") ? I3.workspaces.values : Niri.workspaces

        delegate: MouseArea {
            // important variables
            required property var modelData

            property bool focused : modelData.focused
            property bool active : modelData.active
            property int number : modelData.number
            property int id : modelData.id

            property bool is_hovered: false

            width: parent.width
            height: 30

            hoverEnabled: true
            onEntered: is_hovered = true
            onExited: is_hovered = false

            onClicked: event => {
                switch (event.button) {
                    case Qt.LeftButton:
                        if (I3.socketPath != "") {
                            // i use some script for that but this should work
                            // if not the keyboard just works lol.
                            I3.dispatch(`workspace ${number}`);
                        } else {
                            Niri.focusWs(number - 1);
                            // Hyprland.dispatch(`workspace ${id}`);
                        }
                        break;
                }
            }

            Rectangle {
                id: outer
                color: "#00000000"
                width: parent.width
                height: 30

                Rectangle {
                    id: inner

                    width: focused ? 25 : (parent.parent.is_hovered ? 20 : 10)
                    height: 30
                    color: Theme.fg1

                    anchors {
                        left: parent.left
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }

                BaseText {
                    anchors {
                        centerIn: parent
                    }

                    // stupid way of not showing the text on niri
                    text: (I3.socketPath != "") ? number : ""
                    color: (focused || is_hovered) ? Theme.fg1 : Theme.bg5

                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                        }
                    }
                }
            }
        }
    }
}

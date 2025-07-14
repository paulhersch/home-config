

import Quickshell
import Quickshell.I3
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.DataProviders
import qs.Templates
import qs

RowLayout {
    height: parent.height
    spacing: 10

    Repeater {
        // check if i3 is alive, if not use niri module as source
        model: (I3.socketPath != "") ? I3.workspaces.values : Niri.workspaces

        delegate: MouseArea {
            id: wrapper
            // important variables
            required property bool focused
            required property bool active
            required property int number

            property bool is_hovered: false

            height: parent.height
            width: 30

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
                            Niri.focusWs(number-1);
                        }
                        break;
                }
            }

            Rectangle {
                id: outer
                color: Theme.bg1
                width: 30
                height: parent.height

                Rectangle {
                    id: inner

                    width: wrapper.focused ? 30 : 25
                    height: wrapper.focused ? 25 : 20
                    color: wrapper.focused ? Theme.bgBlue : Theme.bg4

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
                            duration: 300
                        }
                    }
                }

                BaseText {
                    anchors {
                        centerIn: parent
                    }

                    text: wrapper.number
                    color: (wrapper.focused || wrapper.is_hovered) ? Theme.fg1 : Theme.bg5

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

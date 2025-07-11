import Quickshell
import Quickshell.I3
import Quickshell.Widgets
import QtQuick

ListView {
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
            height: text.height + 10
            color: "#eee"

            Text {
                id: text
                // actual stuff happening here
                text: wrapper.number
                color: active ? "blue" : "black"
                anchors {
                    centerIn: parent
                }

                font {
                    family: "Aporetic With Fallback"
                    pixelSize: 15
                }
            }
        }
    }

    model: I3.workspaces.values
    // model: ListModel {
    //     ListElement { index: 0; active: false; focused: false }
    //     ListElement { index: 1; active: false; focused: false }
    //     ListElement { index: 2; active: false; focused: false }
    //     ListElement { index: 3; active: false; focused: false }
    //     ListElement { index: 4; active: false; focused: false }
    //     ListElement { index: 5; active: false; focused: false }
    //     ListElement { index: 6; active: false; focused: false }
    //     ListElement { index: 7; active: false; focused: false }
    //     ListElement { index: 8; active: false; focused: false }
    // }
    delegate: wsComp
}

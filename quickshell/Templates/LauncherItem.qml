import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import QtQuick.Effects

import qs

Rectangle {
    id: root
    required property var modelData

    width: parent.width
    implicitHeight: 50
    color: "transparent"

    RectangularShadow {
        anchors.fill: item
        blur: 0
        spread: 1
        offset {
            x: 6
            y: 6
        }

        color: Theme.fg1
    }

    Rectangle {
        id: item
        color: root.ListView.isCurrentItem ? Theme.bg1 : Theme.bg3
        width: parent.width - 10
        implicitHeight: parent.height - 10

        border {
            color: Theme.fg3
            width: 1
        }

        // gradient: Gradient {
        //     GradientStop {
        //         position: 0.0
        //         color: root.ListView.isCurrentItem ? Theme.fgPurple : Theme.bg3
        //     }
        //     GradientStop {
        //         position: 0.5
        //         color: root.ListView.isCurrentItem ? Theme.bgPurple : Theme.bg1
        //     }
        //     GradientStop {
        //         position: 0.7
        //         color: root.ListView.isCurrentItem ? Theme.bgPurple : Theme.bg1
        //     }
        //     GradientStop {
        //         position: 1
        //         color: root.ListView.isCurrentItem ? Theme.fgPurple : Theme.bg3
        //     }
        // }

        RowLayout {
            anchors {
                left: parent.left
                leftMargin: 15
                rightMargin: 15
            }

            // Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            spacing: 20

            height: parent.height

            IconImage {
                id: icon
                source: Helpers.handledIcons(modelData.icon)
                implicitSize: 32
            }

            BaseText {
                font.pointSize : Theme.fontLarge
                text: modelData.name
            }
        }
    }
}

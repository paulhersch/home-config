import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs

Rectangle {
    id: root
    required property var modelData

    width: parent.width
    implicitHeight: 40
    color: root.ListView.isCurrentItem ? Theme.bgPurple : Theme.bg2

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

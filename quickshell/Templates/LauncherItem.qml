import QtQuick
import Quickshell

import "root:/"

Rectangle {
    id: root
    required property var modelData

    implicitWidth: parent.width
    implicitHeight: 40
    color: root.ListView.isCurrentItem ? Theme.bgPurple : Theme.bg2

    BaseText {
        anchors {}
        text: modelData.name
    }
}


// BaseText {
//     required property var modelData
//     text: modelData.name
// }

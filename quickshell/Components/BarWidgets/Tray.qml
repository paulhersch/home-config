import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qs.Templates

// MouseArea {
//     hoverEnabled: true
//
//     onEntered: layout.spacing = 15
//     onExited: layout.spacing = 2
//     width: layout.width

    RowLayout {
        id: layout
        spacing: 5
        uniformCellSizes: true

        height: parent.height

        Layout.alignment: Qt.AlignCenter

        // Behavior on spacing {
        //     NumberAnimation { duration: 100 }
        // }

        Repeater {
            model: SystemTray.items.values
            delegate: TrayItem {}
        }
    }
// }

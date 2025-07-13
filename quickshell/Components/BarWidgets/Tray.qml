import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

import "root:/Templates"

RowLayout {
    spacing: 10
    uniformCellSizes: true
    
    Layout.alignment: Qt.AlignCenter

    Repeater {
        model: SystemTray.items.values
        delegate: TrayItem {}
    }
}

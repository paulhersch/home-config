import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.I3
import Quickshell.Widgets


import "root:/"
import "root:/Templates"
import "root:/Components/DataProviders" as Providers

RowLayout {
    spacing: 10
    uniformCellSizes: false
    Layout.alignment: Qt.AlignCenter

    Repeater {
        // Only create Windows if Niri exists
        model: (I3.socketPath != "") ? ListModel({}) : Providers.Niri.windows
        delegate: WindowItem {
            socket: Providers.Niri
        }
    }
}

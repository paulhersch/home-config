import Quickshell
import Quickshell.Services.UPower
import QtQuick.Controls

Button {
    // Component {
    //     id: batt
    width: bar.width
    hoverEnabled: true

    ProgressBar {
        id: bar
        from: 0
        to: 1
        value: UPower.devices.values[0].percentage
        anchors {
            centerIn: parent
        }
    }

    function secondsToCoolString(seconds: real): string {
        return `${Math.floor(seconds / 3600)}:${Math.floor((seconds / 60) % 60)}:${Math.floor(seconds % 60)}`;
    }

    ToolTip {
        delay: 1000
        visible: hovered
        text: `${secondsToCoolString(UPower.devices.values[0].timeToEmpty)} / ${UPower.devices.values[0].timeToFull}`
    }
}

    // Component {
    //     id: line
    //     Text {
    //         text: "none"
    //     }
    // }
    // Upower.onBattery ? batt : line
// }

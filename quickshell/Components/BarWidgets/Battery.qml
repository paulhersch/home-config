import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs

// lazily load any relevant laptopbattery
RowLayout  {
    Component {
        id: bat

        MouseArea {
            required property real timeToEmpty
            required property real timeToFull
            required property bool isLaptopBattery
            required property real percentage

            width: 65
            height: 18
            hoverEnabled: true
            id: root

            Rectangle {
                id: bar
                anchors.left: parent.left
                width: parent.width - 15
                height: parent.height

                color: "transparent"
                radius: 5
                border {
                    width: 1
                    color: Theme.fg1
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        margins: 2
                    }
                    radius: parent.radius
                    height: parent.height - 4
                    width: parent.width * percentage
                    color: percentage > 0.4 ? Theme.bgGreen : (percentage < 0.2 ? Theme.bgRed : Theme.bgYellow)
                }
            }

            Rectangle {
                id: tip
                anchors.left : bar.right
                anchors.verticalCenter: bar.verticalCenter
                height: 10
                width: 5
                radius: 5
                color: Theme.fg1
            }

            function secondsToCoolString(seconds: real): string {
                return `${Math.floor(seconds / 3600)}:${Math.floor((seconds / 60) % 60)}:${Math.floor(seconds % 60)}`;
            }
            
            onEntered: { tooltip.visible = true }
            onExited: { tooltip.visible = false }

            ToolTip {
                id: tooltip
                delay: 1000
                text: `${secondsToCoolString(timeToEmpty)} / ${secondsToCoolString(timeToFull)}`
            }
        }
    }

    anchors {
        verticalCenter: parent.verticalCenter
    }

    width: rep.width

    Repeater {
        id: rep
        model: UPower.devices.values.filter(e => e.isLaptopBattery)
        delegate: bat 
    }
}

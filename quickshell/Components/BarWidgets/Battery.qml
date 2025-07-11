import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Controls

// lazily load any relevant laptopbattery
ListView {
    Component {
        id: lazyBatt

        Loader { 
            id: loader
            sourceComponent: isLaptopBattery ? bat : Text({text:""})

            required property real timeToEmpty
            required property real timeToFull
            required property bool isLaptopBattery
            required property real percentage

            Component {
                id: bat
                Button {

                    width: bar.width
                    hoverEnabled: true

                    ProgressBar {
                        id: bar
                        from: 0
                        to: 1
                        value: percentage
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
                        text: `${secondsToCoolString(timeToEmpty)} / ${secondsToCoolString(timeToFull)}`
                    }
                }
            }
        }
    }

    model: UPower.devices
    delegate: lazyBatt
}

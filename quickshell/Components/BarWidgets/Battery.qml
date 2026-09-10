import Quickshell
import Quickshell.Services.UPower
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import qs
import qs.Templates

ColumnLayout  {
    anchors {
        horizontalCenter: parent.horizontalCenter
    }

    spacing: 10

    Repeater {
        id: rep
        model: UPower.devices.values
        width: UPower.devices.values.filter(e => e.isLaptopBattery).length * 85

        DelegateChooser {
            id: chooser
            role: "isLaptopBattery"

            DelegateChoice {
                roleValue: true

                MouseArea {
                    id: root

                    required property real timeToEmpty
                    required property real timeToFull
                    required property bool isLaptopBattery
                    required property real percentage
                    required property string iconName

                    onIconNameChanged: {
                        if (iconName.includes("charg")) {
                            flash.visible = true
                        } else {
                            flash.visible = false
                        }
                    }

                    height: 65
                    width: 20
                    hoverEnabled: true

                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter


                    Rectangle {
                        id: bar
                        anchors.bottom: parent.bottom
                        height: parent.height - tip.height
                        width: parent.width

                        color: "transparent"
                        border {
                            width: 1
                            color: Theme.fg1
                        }

                        Behavior on height {
                            NumberAnimation { duration: 100 }
                        }

                        Rectangle {
                            id: filler
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                                margins: 1
                            }
                            width: parent.width - 2
                            height: parent.height * percentage
                            color: percentage > 0.4 ? Theme.fgGreen : (percentage < 0.2 ? Theme.bgRed : Theme.bgYellow)
                        }

                        // Black Flash under filler
                        IconImage {
                            id: flash
                            implicitSize: 24
                            source: "root:/img/lightning.svg"
                            width: bar.width
                            visible: false
                            anchors.centerIn: bar
                            // color: Theme.fg1
                        }
                    }

                    Rectangle {
                        id: tip
                        anchors.bottom : bar.top
                        anchors.horizontalCenter: bar.horizontalCenter
                        height: 3
                        width: 10
                        color: Theme.fg1
                    }

                    function secondsToCoolString(seconds: real): string {
                        return `${Math.floor(seconds / 3600)}:${Math.floor((seconds / 60) % 60)}:${Math.floor(seconds % 60)}`;
                    }
                }
            }
        }
    }
}

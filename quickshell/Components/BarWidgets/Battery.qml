import Quickshell
import Quickshell.Services.UPower
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import qs
import qs.Templates

RowLayout  {
    anchors {
        verticalCenter: parent.verticalCenter
    }

    width: rep.width
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

                Rectangle {
                    required property real timeToEmpty
                    required property real timeToFull
                    required property bool isLaptopBattery
                    required property real percentage
                    required property string iconName

                    id: trigger
                    width: root.width + 10
                    height: parent.height - 8
                    radius: 0
                    color: Theme.bg2
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                    onIconNameChanged: {
                        if (iconName.includes("charg")) {
                            flash.visible = true
                        } else {
                            flash.visible = false
                        }
                    }

                    MouseArea {
                        visible: isLaptopBattery
                        width: !isLaptopBattery ? 0 : 65
                        height: 18
                        hoverEnabled: true
                        id: root
                        anchors.centerIn: parent

                        property bool isHovered: false

                        Rectangle {
                            id: bar
                            anchors.left: parent.left
                            width: parent.width - (root.isHovered ? 35 : 5)
                            height: parent.height

                            color: "transparent"
                            radius: 5
                            border {
                                width: 1
                                color: Theme.fg1
                            }

                            Behavior on width {
                                NumberAnimation { duration: 100 }
                            }

                            Rectangle {
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    margins: 2
                                }
                                radius: parent.radius
                                height: parent.height - 4
                                width: (parent.width - 4) * percentage
                                color: percentage > 0.4 ? Theme.bgGreen : (percentage < 0.2 ? Theme.bgRed : Theme.bgYellow)
                            }

                            IconImage {
                                id: flash
                                implicitSize: 16
                                source: "root:/img/lightning.svg"
                                rotation: 90
                                width: bar.width
                                visible: false
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

                        BaseText {
                            id: text
                            text: `${Math.floor(percentage * 100)}%`
                            anchors.left: tip.right
                            anchors.leftMargin: 5
                            opacity: root.isHovered

                            Behavior on opacity {
                                NumberAnimation { duration: 100 }
                            }
                        }

                        function secondsToCoolString(seconds: real): string {
                            return `${Math.floor(seconds / 3600)}:${Math.floor((seconds / 60) % 60)}:${Math.floor(seconds % 60)}`;
                        }

                        onEntered: { isHovered = true }
                        onExited: { isHovered = false }
                    }
                }
            }
        }
    }
}

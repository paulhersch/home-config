import Quickshell
import Quickshell.Wayland

import QtQuick
import QtQuick.Effects
import qs
import qs.Templates

/*
 *  Double Background Idea, doesn't work visually when moving windows tho
 */

Variants {
    model: Quickshell.screens

    PanelWindow {
        WlrLayershell.namespace: "quickshell-background"
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        
        required property ShellScreen modelData

        screen: modelData
        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }

        margins {
            top: 5
            right: 5
            bottom: 5
            left: Theme.barWidth + 5
        }

        Rectangle { // flips width and height values for sizing to be preserved
            rotation: -90
            anchors.centerIn: parent
            width: parent.height
            height: parent.width

            border {
                width: 2
                color: Theme.fg1
            }
            radius: 10

            Image {
                id: bg
                anchors {
                    fill: parent
                    margins: 2
                }
                source: Theme.backgroundImage
                fillMode: Image.PreserveAspectCrop
                visible: false
            }

            MultiEffect {
                source: bg
                anchors.fill: bg
                maskEnabled: true
                maskSource: mask
            }

            Item {
                id: mask
                width: bg.width
                height: bg.height
                layer.enabled: true
                visible: false

                Rectangle {
                    width: bg.width
                    height: bg.height
                    radius: 10
                    color: "black"
                }
            }
        }
    }
}

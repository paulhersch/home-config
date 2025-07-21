import Quickshell
import Quickshell.Wayland

import QtQuick
import qs
import qs.Templates

Variants {
    model: Quickshell.screens

    PanelWindow {
        WlrLayershell.namespace: "qs-background"
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

        Image {
            anchors.fill: parent
            
            source: Theme.backgroundImage
            fillMode: Image.PreserveAspectCrop
        }

        /*
         *  Fake Shadow
         */
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: (Theme.barHeight - 10  ) / screen.height; color: Theme.fg3 }
                GradientStop { position: (Theme.barHeight + 7 ) / screen.height; color: "transparent" }
            }
        }
    }
}

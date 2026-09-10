import Quickshell
import Quickshell.Wayland

import QtQuick
import qs
import qs.Templates

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

        Image {
            anchors.fill: parent
            
            source: Theme.backgroundImage
            fillMode: Image.PreserveAspectCrop
        }
    }
}

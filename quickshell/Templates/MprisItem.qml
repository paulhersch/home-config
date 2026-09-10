import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import qs
import qs.Templates

Item {
    id: root
    required property var player
    required property var gradientColor
    
    clip: false

    // Gradient for better readability
    Rectangle {
        anchors.fill : parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 1; color:   "#00" +   gradientColor.split("#")[1] }
            GradientStop { position: 0.9; color: "#88" + gradientColor.split("#")[1] }
            GradientStop { position: 0.5; color: "#BB" + gradientColor.split("#")[1] }
            GradientStop { position: 0.1; color: "#88" + gradientColor.split("#")[1] }
            GradientStop { position: 0; color:   "#00" +   gradientColor.split("#")[1] }
        }
    }

    RowLayout {
        uniformCellSizes: false
        spacing: 10
        width : parent.height - 10
        Layout.maximumWidth: parent.height

        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        rotation: -90

        MouseArea {
            width: skipprev.width
            height: skipprev.height
            IconImage {
                id: skipprev
                source: Helpers.handledIcons("media-skip-backward")
                implicitSize: 16
            }
            onClicked: player.previous()
        }

        MouseArea {
            width: playpause.width
            height: playpause.height
            IconImage {
                id: playpause
                source: player.playbackState == MprisPlaybackState.Playing ? Helpers.handledIcons("media-playback-pause") : Helpers.handledIcons("media-playback-start")
                implicitSize: 24
            }
            onClicked: player.togglePlaying()
        }

        MouseArea {
            width: skipnext.width
            height: skipnext.height
            IconImage {
                id: skipnext
                source: Helpers.handledIcons("media-skip-forward")
                implicitSize: 16
            }
            onClicked: player.next()
        }

        ColumnLayout {
            id: textsublayout
            Layout.maximumHeight: parent.height - 80

            BaseText {               
                Layout.fillWidth: true
                text: player.trackTitle
                font.bold: true
            }
            BaseText {
                Layout.fillWidth: true
                text: player.trackArtist
                font.pointSize : Theme.fontSmall
                font.italic : true
            }
        }
    }
}

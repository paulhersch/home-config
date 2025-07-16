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

    Image {
        id: bg
        // color: Mpris.players.values.length > 0 ? Theme.bgRed : Theme.bg2
        source: player.trackArtUrl
        fillMode: Image.PreserveAspectCrop

        // anchors.horizontalCenter : parent.horizontalCenter
        // width: parent.width
        // height: parent.height
        anchors.fill : parent
    }

    Rectangle {
        id: text
        anchors.fill : parent

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: "#FF" + Theme.bg1.split("#")[1] }
            GradientStop { position: 0.1; color: "#DD" + Theme.bg1.split("#")[1] }
            GradientStop { position: 0.5; color: "#BB" + Theme.bg1.split("#")[1] }
            GradientStop { position: 0.9; color: "#DD" + Theme.bg1.split("#")[1] }
            GradientStop { position: 1; color: "#FF" + Theme.bg1.split("#")[1] }
        }
    }

    RowLayout {
        uniformCellSizes: false
        width: root.width
        anchors.verticalCenter: parent.verticalCenter
        
        Layout.fillWidth: false

        ColumnLayout {
            id: textsublayout
            spacing : 2

            Layout.maximumWidth: root.width - 80
            Layout.margins: 2
            
            BaseText {
                // Text doesn't get truncated properly inside layouts?
                text: player.trackTitle.length < 23 ? player.trackTitle : player.trackTitle.slice(0,20) + "..."
                font.bold: true
            }
            BaseText {
                text: player.trackArtist
                font.pointSize : Theme.fontSmall
                font.italic : true
            }
        }

        RowLayout {
            id: controls
            Layout.alignment: Qt.AlignRight

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
        }
    }
}

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import qs
import qs.Templates

/*
 *      Opener Widget
 */
MouseArea {
    id: root
    property var mainPlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    
    width: mainPlayer != null ? 250 : 0
    height: mainPlayer != null ? parent.height : 0
    visible: mainPlayer != null

    MprisItem {
        player: mainPlayer
        width: this.width
        height: this.height
        anchors.fill : parent
        gradientColor: Theme.bg1
    }
}

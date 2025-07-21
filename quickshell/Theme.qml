pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string bg1 : "#E8EAE5"
    readonly property string bg2 : "#DCE0DC"
    readonly property string bg3 : "#D6D9D6"
    readonly property string bg4 : "#CCD0CC"
    readonly property string bg5 : "#9292A2"

    readonly property string fg1 : "#2B2F2F"
    readonly property string fg2 : "#414444"
    readonly property string fg3 : "#6C6F85"

    readonly property string bgRed      :  "#ECB5B5"
    readonly property string bgGreen    :  "#A2D5B5"
    readonly property string bgYellow   :  "#D5D5AB"
    readonly property string bgBlue     :  "#ABDBE5"
    readonly property string bgPurple   :  "#CBB4CB"
    readonly property string bgCyan     :  "#A8D8D0"

    readonly property string fgRed      :  "#6f4d4d"
    readonly property string fgGreen    :  "#4b7548"
    readonly property string fgYellow   :  "#88862a"
    readonly property string fgBlue     :  "#316a92"
    readonly property string fgPurple   :  "#9e599f"
    readonly property string fgCyan     :  "#377b82"

    readonly property string fontFamily : "Aporetic Serif"
    readonly property int fontNormal    : 11
    readonly property int fontLarge     : 14
    readonly property int fontSmall     : 9

    readonly property string backgroundImage: "/home/paul/Bilder/Hintergrundbilder/field.jpg"

    readonly property int barHeight: 40
}

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.I3

import qs
import qs.DataProviders
import qs.Templates

Rectangle {
    width : (I3.socketPath == "") ? info.width + 10 : 0;
    color: Theme.bg2;

    BaseText {
        id: info
        text: (I3.socketPath == "") ? Niri.focusedKbdLayout : "";
        anchors {
            centerIn : parent;
        }
    }
}

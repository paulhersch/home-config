import Quickshell.Widgets
import Quickshell
import QtQuick
import QtQuick.Controls

MouseArea {
    id: root

    required property string title
    required property string tooltipTitle
    required property string tooltipDescription
    required property string icon
    required property bool hasMenu
    required property var menu

    width: img.width
    height: parent.height

    IconImage {
        id: img
        implicitSize: 20
        source: icon

        anchors {
            centerIn: parent
        }
    }

    QsMenuAnchor {
        id: menuAnchor
        menu: root.menu
        anchor.window: root.QsWindow.window
        anchor.rect.x: root.x + root.QsWindow.contentItem?.width
        anchor.rect.y: root.y
        anchor.rect.height: root.height * 3
    }

    onClicked: event => { 
        switch (event.button) {
            case Qt.LeftButton:
            root.hasMenu && menuAnchor.open();
            break;
            default:
            break;
        }
    }
}

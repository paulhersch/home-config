import Quickshell.Widgets
import Quickshell
import QtQuick
import QtQuick.Controls

MouseArea {
    id: root

    required property var modelData
    required property int index

    width: img.width
    height: parent.height

    IconImage {
        id: img
        implicitSize: 20
        source: modelData.icon

        anchors {
            centerIn: parent
        }
    }

    QsMenuAnchor {
        id: menuAnchor
        menu: modelData.menu
        anchor.window: root.QsWindow.window
        anchor.rect.x: root.parent.x + (root.width + root.parent.spacing) * (index + 1)
        anchor.rect.y: root.parent.y
        anchor.rect.height: root.height * 3
    }

    onClicked: event => { 
        switch (event.button) {
            case Qt.LeftButton:
            modelData.hasMenu && menuAnchor.open();
            break;
            default:
            break;
        }
    }
}

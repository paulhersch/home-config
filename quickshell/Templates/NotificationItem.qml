import Quickshell
import Quickshell.Services.Notifications

import qs
import qs.Templates

import QtQuick
import QtQuick.Layouts


Rectangle {
    property var notifHandleMaybe : Notification

    color: Theme.bg3

    border {
        width : 2
        color: Theme.fg3
    }

    // explicit setter for data
    function setNotifContents(n: Notification) : void {
        notifHandleMaybe = n
        summary.text = n.summary
        body.text = n.body

        if (!n.image) {
            var icon_maybe = Helpers.handledIcons(n.appName)
            if (icon_maybe) {
                image.source = icon_maybe
                image.visible = true
            } else {
                image.visible = false
            }
        } else {
            image.source = n.image
            image.visible = true
        }
    }

    RowLayout {
        anchors.fill : parent
        spacing: 5

        Image {
            id: image
            Layout.maximumHeight: 50
            Layout.maximumWidth: 50
            Layout.leftMargin : 5
            
            Layout.fillHeight : true

            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            cache: false
            source: ""
            fillMode: Image.PreserveAspectFit
        }

        ColumnLayout {
            Layout.fillHeight : true
            Layout.leftMargin : image.visible ? 0 : 5
            Layout.rightMargin : 5
            Layout.maximumWidth: parent.width - (image.visible ? image.width : 0) - 5

            spacing: 5

            BaseText {
                id: summary
                Layout.maximumWidth: parent.width
                Layout.fillWidth : true
                font.pointSize : Theme.fontLarge
                font.bold : true
                elide: Text.ElideRight
                text: ""
            }
            BaseText {
                id: body
                Layout.maximumWidth: parent.width
                Layout.fillWidth : true
                // Layout.fillHeight : true
                // wrapMode : Text.WordWrap
                text: ""
            }
        }
    }
}

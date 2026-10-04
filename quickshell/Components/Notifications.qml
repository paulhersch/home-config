import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

import qs
import qs.Templates
import qs.DataProviders

import QtQuick
import QtQuick.Layouts

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: panel

        required property ShellScreen modelData // screen
        anchors {
            bottom: true
            right: true
        }
        screen: modelData

        margins.right: modelData.width / 8 
        margins.bottom: -3

        implicitWidth: modelData.width / 3
        implicitHeight: 15

        Scope {
            NotificationServer {
                id: server
                persistenceSupported : true
                onNotification : (n) => {
                    if (n.transient || n.urgency == NotificationUrgency.Low) {
                        timeout.expiryHandle = n  // handle for notif to expire later
                    } else {
                        n.tracked = true
                    }
                    // reset timeout
                    if (n.expireTimeout > 0) {
                        timeout.interval = n.expireTimeout * 1000
                    } else {
                        timeout.interval = 3000
                    }
                    // if transient, it can expire

                    notifbox.setNotifContents(n)
                    timeout.restart()
                }
            }

            // timer for Notifications
            Timer {
                property var expiryHandle : Notification  // expire if timeout

                id: timeout
                repeat: false
                running: false

                onTriggered : {
                    if (expiryHandle) {
                        if (expiryHandle.urgency < NotificationUrgency.Normal) {
                            expiryHandle.expire()
                        }
                    }
                }
            }
        }

        // Popup for incoming notifications
        PopupWindow {
            id : notifwin
            anchor.window : panel
            anchor.rect.y : -height
            anchor.rect.x : 0

            implicitWidth: panel.width / 2
            implicitHeight: 100
            color: "transparent"

            NotificationItem {
                id: notifbox
                width: notifwin.width
                anchors.bottom : parent.bottom
                anchors.left : parent.left

                // extra mouse area to allow dismissal and activation
                MouseArea {
                    anchors.fill : parent
                    onClicked : (e) => {
                        if (e.button == Qt.LeftButton) {
                            if (notifbox.notifHandleMaybe) {
                                notifbox.notifHandleMaybe.dismiss()
                                // also shorten the timeout now
                                timeout.stop()
                            }
                        }
                    }
                }

                states : [
                    State { name: "OPEN" },
                    State { name: "CLOSE" }
                ]
                state: timeout.running ? "OPEN" : "CLOSE"
                transitions : [
                    Transition {
                        from: "CLOSE"
                        to: "OPEN"
                        SequentialAnimation {
                            PropertyAction {
                                target: notifwin
                                property : "visible"
                                value : true
                            }
                            NumberAnimation {
                                target : notifbox
                                properties: "height"
                                from: 0
                                to: notifwin.height
                                duration: 150
                                easing: Easing.InQuad
                            }
                        }
                    },
                    Transition {
                        from: "OPEN"
                        to: "CLOSE"
                        SequentialAnimation {
                            NumberAnimation {
                                target : notifbox
                                properties: "height"
                                from: notifwin.height
                                to: 0 
                                duration: 150
                                easing: Easing.OutQuad
                            }
                            PropertyAction {
                                target: notifwin
                                property : "visible"
                                value : false
                            }
                        }
                    }
                ]
            }
        }

        Rectangle {
            anchors.fill : parent
            color: Theme.bg1

            border {
                width: 3
                color: Theme.fg1
            }
            
            MouseArea {
                anchors.fill : parent
                id: trigger
                hoverEnabled : true

                onEntered : () => {
                    centerRoot.state = "OPEN"
                    notifcenterTimer.stop()
                }
                onExited : () => { notifcenterTimer.restart() }
            }

            RowLayout {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10

                layoutDirection: Qt.RightToLeft

                Repeater {
                    model : server.trackedNotifications.values
                    delegate : Rectangle {
                        required property var modelData
                        width: 5
                        height: 5
                        color : modelData.urgency == NotificationUrgency.Critical ? Theme.fgRed : Theme.fg1
                    }
                }
            }
        }

        // Popup for Notificationcenter
        PopupWindow {
            id : notifcenter
            anchor.window : panel
            anchor.rect.y : -height
            anchor.rect.x : panel.width - width

            implicitWidth: panel.width / 2
            implicitHeight: panel.modelData.height / 3
            color: "transparent"

            Timer {
                // timeout to hide notifcenter
                id: notifcenterTimer
                interval: 500
                repeat: false
                running: false

                onTriggered : () => {
                    centerRoot.state = "CLOSE"
                }
            }

            MouseArea {
                anchors.fill : parent
                hoverEnabled : true
                onEntered : () => {
                    centerRoot.state = "OPEN"
                    notifcenterTimer.stop()
                }
                onExited : () => { notifcenterTimer.restart() }
            }

            Rectangle {
                id: centerRoot
                color : Theme.bg1
                border {
                    width : 2
                    color: Theme.fg1
                }
                width: parent.width
                anchors.bottom : parent.bottom 

                ListView {
                    visible: server.trackedNotifications.values.length > 0

                    width: parent.width - 10
                    height: parent.height - 10  
                    anchors.margins : 5
                    anchors.centerIn: parent

                    spacing: 3
                    model : server.trackedNotifications
                    focus : false

                    delegate : NotificationItem {
                        required property var modelData

                        width: parent.width
                        height: 70

                        border.color : modelData.urgency == NotificationUrgency.Critical ? Theme.fgRed : Theme.fg1
                        border.width : modelData.urgency == NotificationUrgency.Critical ? 4 : 2

                        Component.onCompleted : () => {
                            setNotifContents(modelData)
                        }

                        MouseArea {
                            anchors.fill : parent
                            acceptedButtons : Qt.RightButton
                            onClicked : (e) => {
                                console.log(`${timeout.expiryHandle.id} | ${modelData.id}`)
                                if (timeout.expiryHandle.id == modelData.id) {
                                    timeout.stop()
                                }
                                modelData.dismiss()
                            }
                        }
                    }
                }
                
                ColumnLayout {
                    visible: server.trackedNotifications.values.length == 0
                    anchors.centerIn : parent
                    IconImage {
                        Layout.alignment: Qt.AlignHCenter
                        implicitSize : 48
                        source: Helpers.handledIcons("face-yawn")
                    }
                    BaseText {
                        text: "<i>Nothing to see mate</i>"
                        color: Theme.fg3
                    }
                }
                
                // Opening and closing animations, need be in something else than PopupWindow
                states : [
                    State { name: "OPEN" },
                    State { name: "CLOSE" }
                ]
                state: notifcenterTimer.running ? "OPEN" : "CLOSE"
                transitions : [
                    Transition {
                        from: "CLOSE"
                        to: "OPEN"
                        SequentialAnimation {
                            PropertyAction {
                                target: notifcenter
                                property : "visible"
                                value : true
                            }
                            NumberAnimation {
                                target : centerRoot
                                properties: "height"
                                from: 0
                                to: notifcenter.height
                                duration: 50
                                easing: Easing.InQuad
                            }
                        }
                    },
                    Transition {
                        from: "OPEN"
                        to: "CLOSE"
                        SequentialAnimation {
                            NumberAnimation {
                                target : centerRoot
                                properties: "height"
                                from: notifcenter.height
                                to: 0 
                                duration: 150
                                easing: Easing.OutQuad
                            }
                            PropertyAction {
                                target: notifcenter
                                property : "visible"
                                value : false
                            }
                        }
                    }
                ]
            }
        }
    }
}

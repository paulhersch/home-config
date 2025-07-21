import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

import qs
import qs.Templates

MouseArea {
    id: root
    hoverEnabled: true

    property bool hadPreviousTimeout: false

    onEntered: {
        if (timeout.running) {
            timeout.stop()
            hadPreviousTimeout = true
            timerVisual.state = "PAUSED"
        }
    }

    onExited: {
        if (hadPreviousTimeout) {
            timeout.restart()
            hadPreviousTimeout = false
            timerVisual.state = "RUNNING"
        }
    }

    height: parent.height - 5
    // color: "transparent"
    
    RectangularShadow {
        id: shadow
        anchors.fill: mainPill
        radius: mainPill.radius
        blur: 15
        spread: -2
        opacity: mainPill.opacity

        color: Theme.fgGreen
    }

    Rectangle {
        id : mainPill
        anchors {
            centerIn: parent
        }

        height: parent.height
        width: 50
        opacity: 0
        radius: this.height / 2
        color: Theme.bgGreen

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 100
            }
        }

        RowLayout {
            anchors.leftMargin: parent.height / 2
            anchors.rightMargin: parent.height / 2
            anchors.left : parent.left
            anchors.right : parent.right

            width: parent.width
            height: parent.height

            spacing: 5

            IconImage {
                id: icon
                implicitSize: 24
                visible: false
            }

            BaseText {
                id: body
                Layout.fillWidth : true
                text : ""
            }
        }

        // Progress Bar
        Rectangle {
            id: timerVisual

            property real progress: 1

            anchors {
                bottom: parent.bottom
                leftMargin: parent.height / 2
                left : parent.left
            }

            width: progress * (parent.width - parent.height)
            height: 2
            color: Theme.fg1

            states : [
                State {
                    name: "RUNNING"
                    PropertyChanges { target: timerVisual; progress : 1 }
                },
                State {
                    name: "PAUSED"
                    PropertyChanges { target: timerVisual; progress : 0 }
                }
            ]

            state: "PAUSED"

            transitions : [
                Transition {
                    from: "PAUSED"
                    to: "RUNNING"
                    NumberAnimation {
                        properties: "progress"
                        target: timerVisual
                        duration: timeout.interval
                    }
                }
            ]
        }
    }

    Timer {
        id: timeout
        interval: 4000
        repeat: false
        running: false

        onTriggered: {
            mainPill.width = 50
            mainPill.opacity = 0
            icon.visible = false
            timerVisual.state = "PAUSED"
        }
    }

    NotificationServer {
        onNotification : notification => {
            let icon_source_maybe = Helpers.handledIcons(notification.appIcon, notification.appName)
            if (icon_source_maybe) {
                icon.source = icon_source_maybe
                icon.visible = true
            } else if (notification.appIcon != "") {
                icon.source = notification.appIcon
                icon.visible = true
            }

            body.text = [notification.summary,notification.body].filter(e => e != "").join(" - ")
            // actually show notification
            mainPill.width = root.width
            mainPill.height = root.height
            mainPill.opacity = 1

            if (notification.urgency == NotificationUrgency.Critical) {
                mainPill.color = Theme.bgRed
                shadow.color = Theme.fgRed
            } else {
                mainPill.color = Theme.bgGreen
                shadow.color = Theme.fgGreen
            }

            timerVisual.state = "PAUSED"
            timerVisual.state = "RUNNING"
            timeout.restart()
        }
    }
}

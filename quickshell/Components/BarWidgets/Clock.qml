import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland

import qs.Templates
import qs

MouseArea {
    id: root
    Scope{
        SystemClock {
            id: provider
            precision: SystemClock.Minutes
        }
    }

    property bool isHovered

    width: parent.width
    height: trigger.height

    hoverEnabled: true

    cursorShape: Qt.PointingHandCursor
    onEntered : {
        isHovered = true
    }
    onExited : {
        isHovered = false
    }
    onClicked : {
        calendar.visible = !calendar.visible
    }

    Rectangle {
        id: trigger
        width: parent.width
        height: tlayout.height + 10
        color: "#00000000"
        anchors.horizontalCenter: parent.horizontalCenter
    
        ColumnLayout {
            id: tlayout
            width: parent.width
            anchors.centerIn: parent

            BaseText {
                Layout.alignment: Qt.AlignHCenter
                font.pointSize: Theme.fontLarge
                font.bold: true
                text: Qt.formatDateTime(provider.date, Theme.locale, "ddd").toUpperCase().slice(0,2)
                color: root.isHovered || calendar.visible ? Theme.fg3 : Theme.fg1
            }
            BaseText {
                font.pointSize: Theme.fontLarge
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(provider.date, "HH")
                color: root.isHovered || calendar.visible ? Theme.fg3 : Theme.fg1
            }
            BaseText {
                font.pointSize: Theme.fontLarge
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(provider.date, "mm")
                color: root.isHovered || calendar.visible ? Theme.fg3 : Theme.fg1
            }
        }
    }

    PopupWindow {
        // WlrLayershell.namespace: "quickshell-popup"
        id: calendar
        anchor {
            // gravity: Edges.Left | Edges.Bottom
            edges: Edges.Right | Edges.Bottom
            // margins.left: -10
            margins.left: clock.parent.width
            item: root
        }

        implicitWidth: layout.width
        implicitHeight: layout.height

        Rectangle {
            anchors.fill : parent
            // border.color : Theme.fg1
            // border.width : 1
            color: Theme.bg2

            GridLayout {
                anchors.centerIn: parent
                Layout.margins: 2
                id: layout
                columns: 2
                columnSpacing: 0
                rowSpacing: 0

                DayOfWeekRow {
                    locale: grid.locale

                    Layout.column: 1
                    // Layout.fillWidth: true
                    implicitWidth: 500

                    delegate: BaseText {
                        required property var model
                        text: model.shortName
                        font.bold: true
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                WeekNumberColumn {
                    month: grid.month
                    year: grid.year
                    locale: grid.locale

                    Layout.fillHeight: true

                    delegate : BaseText {
                        required property var model
                        text: model.weekNumber
                        color: Theme.fgPurple
                        Layout.alignment: Qt.AlignTop
                        Layout.fillHeight: true
                    }
                }

                MonthGrid {
                    id: grid
                    locale: Theme.locale

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 1

                    // getYear gets the Year with current year - 1900 for some fucking reason
                    year: provider.date.getFullYear()
                    month: provider.date.getMonth()

                    spacing: 0

                    readonly property int gridLineThickness: 1

                    implicitWidth: 300
                    implicitHeight: 300

                    background: Item {
                        x: grid.leftPadding
                        y: grid.topPadding
                        width: grid.availableWidth
                        height: grid.availableHeight

                        // Vertical lines
                        Row {
                            spacing: (parent.width - (grid.gridLineThickness * rowRepeater.model)) / (rowRepeater.model-1)
                            Repeater {
                                id: rowRepeater
                                model: 8
                                delegate: Rectangle {
                                    width: grid.gridLineThickness
                                    height: grid.height
                                    color: "#ccc"
                                }
                            }
                        }

                        // Horizontal lines
                        Column {
                            spacing: (parent.height - (grid.gridLineThickness * columnRepeater.model)) / (columnRepeater.model - 1)
                            Repeater {
                                id: columnRepeater
                                model: 7
                                delegate: Rectangle {
                                    width: grid.width
                                    height: grid.gridLineThickness
                                    color: "#ccc"
                                }
                            }
                        }
                    }

                    delegate : BaseText {
                        required property var model
                        anchors {
                            margins: 5
                        }

                        id: monthText
                        opacity : model.month === provider.date.getMonth() ? 1 : 0.3
                        text: model.day
                        color: model.today ? Theme.fgBlue : Theme.fg1
                        font.bold: model.today
                    }
                }
            }
        }
    }
}

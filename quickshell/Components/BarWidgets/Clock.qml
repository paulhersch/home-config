import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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

    width: trigger.width
    height: parent.height
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
        width: clock.width + 10
        height: parent.height - 8
        radius: 0
        color: root.isHovered || calendar.visible ? Theme.bgBlue : Theme.bg2
        anchors.centerIn: parent

        BaseText {
            anchors.centerIn: parent
            id: clock
            text: Qt.formatDateTime(provider.date, "ddd, dd.MM u'm' HH:mm")
        }
    }

    PopupWindow {
        id: calendar
        anchor {
            gravity: Edges.Left | Edges.Bottom
            edges: Edges.Right | Edges.Bottom
            margins.right: - 10
            margins.top: (clock.parent.height - clock.height)
            item: root
        }

        implicitWidth: layout.width + 20
        implicitHeight: layout.height + 20

        Rectangle {
            color: Theme.bg1
            anchors.fill : parent
        }

        GridLayout {
            anchors.centerIn: parent
            Layout.margins: 0
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
                locale: Qt.locale("de_DE")

                Layout.fillWidth: true
                Layout.fillHeight: true
                year: provider.date.getYear()
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

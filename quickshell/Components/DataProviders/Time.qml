pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property string time

    // Update Clock Widget
    Process {
        id: clockUpdate
        running: true // instant first update
        command: [ "date", "+%a, %d.%m %H:%M" ]
        stdout: StdioCollector {
            onStreamFinished: root.time = this.text
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: clockUpdate.running = true
    }
}

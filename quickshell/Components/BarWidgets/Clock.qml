import Quickshell
import QtQuick

import "root:/Templates"

BaseText {

    SystemClock {
        id: provider
        precision: SystemClock.Minutes
    }

    id: clock
    text: Qt.formatDateTime(provider.date, "ddd, dd.mm u'm' HH:MM")
}

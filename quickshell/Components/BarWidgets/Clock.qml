import Quickshell
import QtQuick

import qs.Templates

BaseText {
    Scope{
        SystemClock {
            id: provider
            precision: SystemClock.Minutes
        }
    }

    id: clock
    text: Qt.formatDateTime(provider.date, "ddd, dd.MM u'm' HH:mm")
}

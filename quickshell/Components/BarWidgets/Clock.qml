import Quickshell
import QtQuick

import "../DataProviders" as Providers

Text {
    id: clock
    text: Providers.Time.time
    font {
        family: "Aporetic With Fallback"
        pixelSize: 14
    }
}

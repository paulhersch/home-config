pragma Singleton

import Quickshell

Singleton {
    function handledIcons(name) {
        switch (name) {
            case "Signal":
                name = "org.signal.Signal"
                break;
            case "Spotify":
                name = "spotify"
                break;
            default:
                break;
        }
        return Quickshell.iconPath(name)
    }
}

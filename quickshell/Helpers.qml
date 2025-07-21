pragma Singleton

import Quickshell

Singleton {
    function handledIcons(...names) {
        // need to check for pixmap
        for (let i=0; i < names.length; i++) {
            let name = names[i];

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
            let check = Quickshell.iconPath(name, true)
            if (check) return check;
        }
        return null
    }
}

pragma Singleton

import QtQuick
import Quickshell
import "root:/scripts/fzy.js" as Fzy

Singleton {
    id: root

    readonly property list<DesktopEntry> entries: DesktopEntries.applications.values
    .filter(a => !a.noDisplay)
    .sort((a, b) => a.name.localeCompare(b.name))

    function scoreEntry(query, entry: DesktopEntry): real {
        return Fzy.score(query, entry.name) + Fzy.score(query, entry.execString)
    }

    function matchEntry(query, entry: DesktopEntry): real {
        return (
            Fzy.hasMatch(query, entry.name) || Fzy.hasMatch(query, entry.execString)
        )
    }

    function query(text: string): var {
        if (text == undefined){
            return root.entries;
        }
        return root.entries
        .filter((e) => matchEntry(text, e))
        .sort((a ,b) => scoreEntry(text, b) - scoreEntry(text, a))
    }

    function launch(entry: DesktopEntry): void {
        if (entry['runInTerminal'] != undefined && entry.runInTerminal == true) {
            Quickshell.execDetached(["foot", "-c", entry.execString]);
        } else {
            Quickshell.execDetached(["sh", "-c", entry.execString]);
        }
    }
}

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

    function launch(entry: DesktopEntry): void {
        if (entry['runInTerminal'] != undefined && entry['runInTerminal'] == true) {
            Quickshell.execDetached(["foot", "-c", entry.execString]);
        } else {
            // Quickshell.execDetached(["sh", "-c", entry.execString]);
            entry.execute()
        }
    }

    function query(text: string): var {
        if (text == undefined){
            return root.entries;
        }

        // identify special functions by prefix
        // could execute any js
        if (text[0] === '=') {
            let exp = text.split("=")[1];
            try {
                let returnVal = eval(`${exp}`);
                if (typeof returnVal === 'function') {
                    // create Data Points for Plot
                    // 20 points, 0.25 interval should be enough
                    let plotData = [...Array(20).keys()].map(e => returnVal(e / 4));
                    return [{ "name": plotData.toString(), "icon": "wolfram-mathematica", "runInTerminal": false, "execString": "" }]
                }
                return [
                    {"name": returnVal.toString(), "icon": "wolfram-mathematica", "runInTerminal": false, "execString": ""}
                ]
            } catch (error) {
                return [
                    {"name": "Syntax Error", "icon": "wolfram-mathematica", "runInTerminal": false, "execString": ""}
                ]
            }
        }

        // "run" mode
        if (text[0] === '$') {
            let exp = text.split("$")[1];
            return [{ "name": exp, "icon": "terminal", "runInTerminal": true, "execString": exp }]
        }

        return root.entries
        .filter((e) => matchEntry(text, e))
        .sort((a ,b) => scoreEntry(text, b) - scoreEntry(text, a))
    }

}

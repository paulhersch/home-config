pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import QtQml

Singleton {
    id: root
    property var workspaces : ListModel {}
    property var focusedWorkspace : 0

    function parseUpdates(data) {
        let obj = JSON.parse(data);

        // handle certain events
        if (obj["WorkspacesChanged"] != undefined) {
            workspaces.clear()
            let list = obj["WorkspacesChanged"]["workspaces"];
            list.sort((a,b) => a.idx - b.idx)

            list.forEach((e) => {
                let this_idx = e.idx - 1;
                let this_ws = {"id": e.id, "number": e['idx'], "focused": e['is_focused'], "active": e['is_active']};

                if (e['is_focused']) {
                    focusedWorkspace = this_idx;
                }

                workspaces.append(this_ws);
            })
        } else if (obj["WorkspaceActivated"] != undefined) {
            let id = obj["WorkspaceActivated"].id;

            // find index of next workspace that has id
            for (let i=0; i<workspaces.count; i++){
                let ws = workspaces.get(i);
                if (ws.id == id) {
                    workspaces.setProperty(focusedWorkspace,"focused",false)
                    workspaces.setProperty(i,"focused",true)
                    focusedWorkspace = i
                    break;
                }
            }
        }
        // debug
        // for (let i=0; i<workspaces.count; i++){
        //     console.log(JSON.stringify(workspaces.get(i)));
        // }
    }

    Process {
        id: listener
        running: true
        command: [ "niri", "msg", "-j", "event-stream" ]

        stdout: SplitParser {
            onRead: data => root.parseUpdates(data)
        }
    }
}

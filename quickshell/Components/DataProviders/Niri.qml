pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import QtQml

Singleton {
    id: root
    property var workspaces : ListModel {}
    property var windows : ListModel {}
    property var focusedWorkspace : 0
    property var focusedWindowIndex : 0

    function focusWs(idx : int) : void {
        if (idx < workspaces.count) {
            Quickshell.execDetached(["sh", "-c", `niri msg action focus-workspace ${workspaces.get(i).id}`])
        }
    }

    function focusWindow(id : int) : void {
        console.log(`niri msg action focus-window --id=${id}`)
        Quickshell.execDetached(["sh", "-c", `niri msg action focus-window --id=${id}`])
    }

    function listModel(model) {
        for (let i=0; i<model.count; i++) {
            console.log(JSON.stringify(model.get(i)));
        }
    }

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
                    return;
                }
            }
        } else if (obj["WindowsChanged"] != undefined) {
            let list = obj["WindowsChanged"]["windows"];
            windows.clear()
            list.sort((a,b) => a.id < b.id)
            list.forEach((e,k) => {
                windows.append(e)
                if (e["is_focused"]) {
                    focusedWindowIndex = k
                }
            });
        } else if (obj["WindowFocusChanged"] != undefined) {
            let id = obj["WindowFocusChanged"]["id"];
            if (id == null) return;
            for (let i=0; i<windows.count; i++) {
                if (id === windows.get(i).id) {
                    windows.setProperty(focusedWindowIndex, "is_focused", false)
                    windows.setProperty(i,"is_focused",true)
                    focusedWindowIndex = i
                    return;
                }
            }
        } else if (obj["WindowOpenedOrChanged"] != undefined) {
            let data = obj["WindowOpenedOrChanged"]["window"];
            let id = data.id;
            for (let i=0; i<windows.count; i++) {
                if (id === windows.get(i).id) {
                    windows.set(i, data)
                    return;
                }
            }
            windows.append(data)
        } else if (obj["WindowClosed"] != undefined) {
            let id = obj["WindowClosed"]["id"];
            for (let i=0; i<windows.count; i++) {
                if (id === windows.get(i).id) {
                    windows.remove(i, 1);
                    return;
                }
            }
        }
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

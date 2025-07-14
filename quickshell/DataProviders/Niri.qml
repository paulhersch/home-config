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

    property var wsIndexById : {}

    function focusWs(idx : int) : void {
        if (idx < workspaces.count) {
            Quickshell.execDetached(["sh", "-c", `niri msg action focus-workspace ${workspaces.get(idx).id}`])
        }
    }

    function updateWindowFocused(id: int): void {
        for (let i=0; i<windows.count; i++) {
            if (id === windows.get(i).id) {
                windows.setProperty(focusedWindowIndex, "is_focused", false)
                windows.setProperty(i,"is_focused",true)
                focusedWindowIndex = i
                return;
            }
        }
    }

    function focusWindow(id : int) : void {
        console.log(`niri msg action focus-window --id=${id}`)
        Quickshell.execDetached(["sh", "-c", `niri msg action focus-window --id=${id}`])
        // preemptively update the currently focused index
        updateWindowFocused(id)
    }

    function listModel(model) {
        for (let i=0; i<model.count; i++) {
            console.log(JSON.stringify(model.get(i)));
        }
    }

    function sortWindows(winlist: var) {
        winlist.sort((a,b) => ( wsIndexById[a['workspace_id']] - wsIndexById[b['workspace_id']] ))
    }

    function setWindows(winlist: var) {
        windows.clear()
        sortWindows(winlist)
        winlist.forEach((e,k) => {
            windows.append(e)
            if (e["is_focused"]) {
                focusedWindowIndex = k
            }
        });
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
            // assume we have the full list of workspaces, update index list
            wsIndexById = {};
            for (let i=0; i < workspaces.count; i++) {
                let e = workspaces.get(i);
                wsIndexById[e['id']] = e['number']
            }

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
            setWindows(list);
        } else if (obj["WindowOpenedOrChanged"] != undefined) {
            let data = obj["WindowOpenedOrChanged"]["window"];
            let id = data.id;

            for (let i=0; i<windows.count; i++) {
                if (id === windows.get(i).id) {
                    windows.set(i, data)
                    // did we move the window to lower indexed workspaces?
                    while (i > 1 && windows.get(i - 1)['workspace_id'] > windows.get(i)['workspace_id']) {
                        windows.move(i, i-1, 1)
                        i--;
                        if (data.is_focused) focusedWindowIndex--;
                    }

                    while (i < windows.count - 1 && windows.get(i + 1)['workspace_id'] < windows.get(i)['workspace_id']) {
                        windows.move(i, i+1, 1)
                        i++;
                        if (data.is_focused) focusedWindowIndex++;
                    }
                    
                    // WARN: early return!
                    return;
                }
            }
            // we didnt find a window with the same id
            windows.append(data)
            // walk backwards (copy pasted from above)
            let i = windows.count - 1
            while (i > 1 && windows.get(i - 1)['workspace_id'] > windows.get(i)['workspace_id']) {
                windows.move(i, i-1, 1)
                i--;
            }
            if (data.is_focused) focusedWindowIndex = i;
        } else if (obj["WindowFocusChanged"] != undefined) {
            let id = obj["WindowFocusChanged"]["id"];
            if (id == null) return;
            updateWindowFocused(id);
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

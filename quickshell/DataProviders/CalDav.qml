pragma Singleton

import Quickshell
import QtQuick


Singleton {
        component CalEvent : Item {
            property string title
            property string description
            property date date
        }

        component CalSource : Item {
            property string description
            property string url
            property string secret

            property var events : ListModel {}

            function request(url, callback) {
                var xhr = new XMLHttpRequest();
                xhr.onreadystatechange = (function(myxhr) {
                    return function() {
                        if(myxhr.readyState === 4) callback(myxhr);
                    }
                })(xhr);
                xhr.open('GET', url, true);
                xhr.send('');
            }

            function sync() : void {
                // XHR.sendRequest(
                //     "https://cloud.gemia.net/remote.php/dav/calendars/34339a20-c680-4ff5-8f83-2345d57ea39e/personal?export&accept=jcal",
                //     function(response)
                // )
            }
        }

    id: root

    property var sources : ListModel {}

    function sync() : void {
        for (let i=0; i < sources.count; i++) {
            sources.get(i).sync();
        }
    }

    function getEvents() : var {
        let list = [];
        for (let i=0; i < sources.count; i++) {
            list = list.concat(sources.get(i).events);
        }
        return list;
    }
}

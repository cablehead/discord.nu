#!/usr/bin/env -S nu

alias and-then = if ($in | is-not-empty)

# unfortunately `else` can't be included in the alias
alias ? = if ($in | is-not-empty) { $in }
alias ?? = ? else { return }

use xs.nu
use discord/

let store = "./store"
let path = "./state.nuon"

let state = try { open $path } catch { {last_id: null, app: (discord heartbeat default-state)} }
print ($state | table -e)

let ws_send = {|| to json -r | xs append $store ws.send}

xs cat $store --last-id=$state.last_id --follow 5000
    | where { |clip|
        ($clip.topic | str starts-with "ws.") or ($clip.topic in [ "stream.cross.threshold", "stream.cross.pulse" ])
    }
    | each { |clip|
        if ($clip.hash | is-empty) { $clip } else {
            insert data {|row|
                xs cas ./store $row.hash | from json
            }}
    }
    | each { |clip|
        let state = try { open $path } catch { {last_id: null, app: (discord heartbeat default-state)} }
        print ($state | table -e)
        print ($clip | table -e)
         discord heartbeat run $state.app $ws_send $clip | if ($in | is-not-empty) {
             {last_id: $clip.id, app: $in} | save -f $path
             print (open $path | table -e)
         }
    }




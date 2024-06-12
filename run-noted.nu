#!/usr/bin/env -S nu

alias and-then = if ($in | is-not-empty)

# unfortunately `else` can't be included in the alias
alias ? = if ($in | is-not-empty) { $in }
alias ?? = ? else { return }

use xs.nu
use discord/

let store = "./store"
let path = "./run-noted-state.nuon"

let stash = {|clip| $clip.data | to json -r | save -f $"./foo/($clip.id).nuon"}

let state = try { open $path } catch { {last_id: null} }
print starting ($state | table -e)

xs cat $store --last-id=$state.last_id --follow yes | each {|clip|
    if ($clip.hash | is-empty) { $clip } else {
        insert data {|row|
            xs cas ./store $row.hash | from json
        }}
    } | each {|clip|
        mut state = try { open $path } catch { {last_id: null, app: {}} }
        print ($state | table -e)
        print ($clip | table -e)

        if ($clip.topic == "ws.recv" and $clip.data.op == 0) {
            if ($clip.data.t in [
                    "MESSAGE_CREATE"
                    "MESSAGE_DELETE"
                    "MESSAGE_UPDATE"
                    "MESSAGE_REACTION_REMOVE"
                    "MESSAGE_REACTION_ADD"
                    "MESSAGE_REACTION_REMOVE_ALL"
            ]) {
                do $stash $clip

            } else if ($clip.data.t not-in [ "READY", "GUILD_CREATE", "RESUMED" ]) {
                print "exit"
                exit
            }
        }

        $state.last_id = $clip.id
        $state | save -f $path
        print (open $path | table -e)

         # discord heartbeat run $state.app $ws_send $clip | if ($in | is-not-empty) {
             # {last_id: $clip.id, app: $in} | save -f $path
             # print (open $path | table -e)
         # }
     }




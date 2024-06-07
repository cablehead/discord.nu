#!/usr/bin/env -S nu

alias and-then = if ($in | is-not-empty)

# unfortunately `else` can't be included in the alias
alias ? = if ($in | is-not-empty) { $in }
alias ?? = ? else { return }

use xs.nu
use discord/

let path = "./state.nuon"

let state = try { open $path } catch { {last_id: null, app: {}} }
print ($state | table -e)

let clip = xs cat ./store/ --last-id=$state.last_id
    | first
    | insert data { |row| xs cas ./store $row.hash | from json }

print ($clip | table -e)

discord heartbeat run $state.app $clip | {last_id: $clip.id, app: $in} | save -f $path
print (open $path | table -e)

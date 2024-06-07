#!/usr/bin/env -S nu

alias and-then = if ($in | is-not-empty)

# unfortunately `else` can't be included in the alias
alias ? = if ($in | is-not-empty) { $in }
alias ?? = ? else { return }

use xs.nu
use one.nu run 

let path = "./state.nuon"

let state = try { open $path } catch { {last_id: null, state: {}} }

let clip = xs cat ./store/ --last-id=$state.last_id
    | first
    | insert data { |row| xs cas ./store $row.hash | from json }

let state = run $state $clip
print ($state | table -e)


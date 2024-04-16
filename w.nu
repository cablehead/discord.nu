#!/usr/bin/env -S nu 

alias and-then = if ($in | is-not-empty)
alias ? = if ($in | is-not-empty) { $in }
alias ?? = ? else { return }


export def "xs cat" [...params] {
    xs ./ws cat ...$params |
        lines |
        each { from json } |
        update data { from json } |
        default "" topic 
}

def flatten-params [params] {
    $params | columns | each {|name|
        $params | get $name | and-then { 
            let value = $in
            if $value == true {
                [$name]
            } else { 
                [$name, $value]
            }

        } 
    } | flatten
}


loop {
  let params = ( try { open last_id } | and-then {{"--last-id": $in}})
  xs cat  ...(flatten-params $params) |  each { 
      let r = $in
      $r.id | save -f last_id
      print ($r | table --expand)
  }
  sleep 1sec
}

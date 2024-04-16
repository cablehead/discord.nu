#!/usr/bin/env -S nu --stdin

alias and-then = if ($in | is-not-empty)
alias ? = if ($in | is-not-empty) { $in }
alias ?? = ? else { return }

let origin = "wss://gateway.discord.gg"
# let origin = "ws://127.0.0.1:1234"

export def "xs cat" [...params] {
    xs ./ws cat ...$params |
        lines |
        each { from json } |
        update data { from json } |
        default "" topic 
}

def ws [url] {
   websocat $url --ping-interval 5 --ping-timeout 10 -E -t
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

def "main watch" [] {
    loop {
      let params = ( try { open last_id } | and-then {{"--last-id": $in}})
      xs cat  ...(flatten-params $params) |  each {
          let r = $in
          $r.id | save -f last_id
          print ($r | table --expand)
      }
      sleep 1sec
    }
}

def main [...args] {
    print "start"

    let params = {
        "--follow": true,
        "--last-id": (xs cat | last | and-then { $in.id }),
    }

    xs cat ...(flatten-params $params) |
        where topic == "ws.send" | each { get data | to json -r } | to text |
        websocat $origin --ping-interval 5 --ping-timeout 10 -E -t |
        xs ./ws put --follow --topic ws.recv

    print "peace"
    return
}

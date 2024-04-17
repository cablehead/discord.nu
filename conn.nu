#!/usr/bin/env -S nu --stdin

alias and-then = if ($in | is-not-empty)

# unfortunately `else` can't be included in the alias
alias ? = if ($in | is-not-empty) { $in }
alias ?? = ? else { return }

# `? else` instead of `map-empty`
# : if true  { {foo: "goo"} } | ? else { {foo: "bar"} } | get foo
# goo
# : if false { {foo: "goo"} } | ? else { {foo: "bar"} } | get foo
# bar

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

def "main heartbeat" [path] {

mut state = ( try { open $path } | ? else { { 
        last_id: null,
        s: 0,
        heartbeat_interval: 0, # 0 means we are offline
        last_sent: ""
        last_ack: ""
    } }
    )

      let params = (flatten-params {"--last-id": $state.last_id})

        let event = (xs cat ...$params | ? else { 
            print "noop" 
            return
        } | first)

        print ($state | table -e)

        print ($event | table -e)


        match $event.data.op {
    10 => {
            $state.heartbeat_interval = $event.data.d.heartbeat_interval
            $state.last_ack = $event.id
    },
    _ => {
        print "TODO"
        return
    }
}




        print ($state | table -e)
        

    $state.last_id = $event.id

    $state | save -f $path


return


      # let params = ( try { open last_id } | and-then {{"--last-id": $in}})
      let params = {}
      xs cat  ...
      # (flatten-params {"--last-id") |  each {
          let r = $in

          $r | save goo.json
          return


          print $"s: ($r.data.s | describe)"
          # $r.id | save -f last_id
          # print ($r | table --expand)
}

def "main connect" [] {
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

def main [] {
    print "i'm the main"
}

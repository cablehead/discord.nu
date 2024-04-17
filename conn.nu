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

const opcode = {
    dispatch: 0,
    heartbeat: 1,
    identify: 2,
    presence_update: 3,
    voice_update: 4,
    resume: 6,
    reconnect: 7,
    invalid_session: 9,
    hello: 10,
    heartbeat_ack: 11,
}

def "op heartbeat" [seqno?: int] {
    {
        "op": $opcode.heartbeat,
        "d": $seqno,
    }
}

def "op identify" [token: string, intents: int] {
    {
        "op": $opcode.identify,
        "d": {
            token: $token,
            intents: $intents,
            properties: {
                os: (sys | get host.name),
                browser: "discord.nu",
                device: "discord.nu",
            },
        },
    }
}

def "op resume" [token: string, session_id: string, seq: int] {
    {
        "op": $opcode.resume,
        "d": {
            token: $token,
            session_id: $session_id,
            seq: $seq,
        },
    }
}

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

def "scru128-since" [$id1, $id2] {
    let t1 = ($id1 | scru128 parse | into int)
    let t2 = ($id2 | scru128 parse | into int)
    return ($t1 - $t2)
}

def "main heartbeat" [path] {
    mut state = (try { open $path } | ? else { { 
        last_id: null,
        s: null,
        heartbeat_interval: 0, # 0 means we are offline
        last_sent: null,
        last_ack: null,

        authing: null,
        session_id: null,
        resume_gateway_url: null,
    } })

    let previous = $state

    let params = (flatten-params {"--last-id": $state.last_id})
    let event = (xs cat ...$params | ? else { 
            [{
                id: (scru128), 
                data: {
                    op: -1,
                },
            }]
        } | first)


    match $event.data {
        {op: -1} => {
            # if we're online, but not authed, attempt to auth
            if (($state.heartbeat_interval != 0) and ($state.authing | is-empty)) {
                if ($state.session_id | is-not-empty) {
                    print "sending resume!"
                    op resume $env.BOT_TOKEN $state.session_id $state.s | to json -r | xs ./ws put --topic ws.send
                } else {
                    print "sending identify!"
                    op identify $env.BOT_TOKEN 33281 | to json -r | xs ./ws put --topic ws.send
                }
            } else {
                # if we're offline, or an ack is pending, do nothing
                if (($state.heartbeat_interval == 0) or ($state.last_ack | is-empty)) {
                    return
                }

                let since = (scru128-since $event.id $state.last_sent)
                let interval =  (($state.heartbeat_interval / 1000) * 0.9)
                if ($since > $interval) {
                    print "sending heartbeat!"
                    op heartbeat $state.s | to json -r | xs ./ws put --topic ws.send
                }
            }
            # this is a virtual event, so exit early to avoid updating last_id
            return
        }

        # identify
        {op: 2} => {
            $state.authing = "identify"
        }

        # resume
        {op: 6} => {
            $state.authing = "resume"
        }

        # hello
        {op: 10} => {
            $state.heartbeat_interval = $event.data.d.heartbeat_interval
            $state.last_ack = $event.id
            $state.last_sent = $event.id
            $state.authing = null
        },

        # heartbeat
        {op: 1} => {
            $state.last_ack = null
            $state.last_sent = $event.id
        },

        # heartbeat_ack
        {op: 11} => {
            $state.last_ack = $event.id
        },

        # dispatch
        {op: 0, t: "READY"} => {
            $state.session_id = $event.data.d.session_id
            $state.resume_gateway_url = $event.data.d.resume_gateway_url
        }

        # dispatch
        {op: 0, t: "GUILD_CREATE"} => {}

        # dispatch
        {op: 0, t: "MESSAGE_CREATE"} => {
            print "MESSAGE_CREATE!, TODO"
        }

        {op: 0, t: "MESSAGE_UPDATE"} => {
            print "MESSAGE_UPDATE!, TODO"
        }

        # dispatch
        {op: 0} => {
            print $"TODO: 0, unknown t: ($event.data.t)"
            return
        }

        # invalid_session
        {op: 9} => {
            # if we get an invalid session while trying to resume, also clear
            # out the session
            if $state.authing == "resume" {
                $state.resume_gateway_url = null
                $state.session_id = null
            }
            $state.authing = null
        }

        _ => {
            print "TODO"
            return
        }
    }

    if (($event.data.op == $opcode.dispatch) and ($event.data.s | is-not-empty)) {
        $state.s = $event.data.s
    }

    $state.last_id = $event.id
    $state | save -f $path

    print ($previous | table -e)
    print ($event | table -e)
    print ($state | table -e)
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

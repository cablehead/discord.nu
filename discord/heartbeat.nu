alias and-then = if ($in | is-not-empty)

# unfortunately `else` can't be included in the alias
alias ? = if ($in | is-not-empty) { $in }
alias ?? = ? else { return }

# `? else` instead of `map-empty`
# : if true  { {foo: "goo"} } | ? else { {foo: "bar"} } | get foo
# goo
# : if false { {foo: "goo"} } | ? else { {foo: "bar"} } | get foo
# bar

# state: {
#    last_id: null,
#    s: null,
#    heartbeat_interval: 0, # 0 means we are offline
#    last_sent: null,
#    last_ack: null,
#
#    authing: null,
#    session_id: null,
#    resume_gateway_url: null,
# }

def "scru128-since" [$id1, $id2] {
    let t1 = ($id1 | scru128 parse | into int)
    let t2 = ($id2 | scru128 parse | into int)
    return ($t1 - $t2)
}

export def run [state: record clip: record] {
    if ($clip | get data? | is-empty) {
        print "skip"
        return
    }

    mut state = $state
    match $clip.data {
        # hello
        {op: 10} => {
            $state.heartbeat_interval = $clip.data.d.heartbeat_interval
            $state.last_ack = $clip.id
            $state.last_sent = $clip.id
            $state.authing = null
        },

        # heartbeat
        {op: 1} => {
            $state.last_ack = null
            $state.last_sent = $clip.id
        },

        # heartbeat_ack
        {op: 11} => {
            $state.last_ack = $clip.id
        },

        # reconnect
        {op: 7} => {},

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

        # identify
        {op: 2} => {
            $state.authing = "identify"
        }

        # dispatch
        {op: 0, t: "READY"} => {
            $state.session_id = $clip.data.d.session_id
            $state.resume_gateway_url = $clip.data.d.resume_gateway_url
            $state.authing = "authed"
        }

        {op: 0, t: "GUILD_CREATE"} => {},

        # pulse
        {op: -1} => {
            print "."
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

                let since = (scru128-since $clip.id $state.last_sent)
                let interval =  (($state.heartbeat_interval / 1000) * 0.9)
                if ($since > $interval) {
                    print "sending heartbeat!"
                    op heartbeat $state.s | to json -r | xs ./ws put --topic ws.send
                }
            }
        }

        _ => {
            error make { msg: $"todo ($clip | table -e)" }
        },
    }

    $state
}

use op.nu

def "scru128-since" [$id1, $id2] {
    let t1 = ($id1 | scru128 parse | into int)
    let t2 = ($id2 | scru128 parse | into int)
    return ($t1 - $t2)
}

export def default-state [] {
    {
        s: null,
        heartbeat_interval: 0, # 0 means we are offline
        last_sent: null,
        last_ack: null,

        authing: null,
        session_id: null,
        resume_gateway_url: null,
    }
}

export def run [state: record ws_send: closure clip: record] {
    if ($clip | get data? | is-empty) {
        # if we're online, but not authed, attempt to auth
        if (($state.heartbeat_interval != 0) and ($state.authing | is-empty)) {
            if ($state.session_id | is-not-empty) {
                print "sending resume!"
                op resume $env.BOT_TOKEN $state.session_id $state.s | do $ws_send
            } else {
                print "sending identify!"
                op identify $env.BOT_TOKEN 33281 | do $ws_send
            }
            return
        }

        # if we're offline, or an ack is pending, do nothing
        if ($state.heartbeat_interval == 0) {
            return
        }

        let since = (scru128-since $clip.id $state.last_sent)
        let interval =  (($state.heartbeat_interval / 1000) * 0.9)
        if ($since > $interval) {
            print "sending heartbeat!"
            op heartbeat $state.s | do $ws_send
        }
        return
    }

    mut state = $state

    # * s and t are null when op is not 0
    if (($clip.data.op == 0) and ($clip.data.s | is-not-empty)) {
        $state.s = $clip.data.s
    }

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

        # resume
        {op: 6} => {
            $state.authing = "resume"
        }

        # dispatch
        {op: 0, t: "READY"} => {
            $state.session_id = $clip.data.d.session_id
            $state.resume_gateway_url = $clip.data.d.resume_gateway_url
            $state.authing = "authed"
        }

        {op: 0, t: "RESUMED"} => {
            $state.authing = "authed"
        }

        # catch all for the remainder of dispatch topics (t)
        {op: 0} => {}

        _ => {
            error make { msg: $"todo ($clip | table -e)" }
        },
    }

    $state
}

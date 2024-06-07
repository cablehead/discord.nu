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

export def run [state: record clip: record] {
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

        _ => {
            error make { msg: $"todo ($clip | table -e)" }
        },
    }

    $state
}

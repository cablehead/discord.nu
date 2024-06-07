alias and-then = if ($in | is-not-empty)

# unfortunately `else` can't be included in the alias
alias ? = if ($in | is-not-empty) { $in }
alias ?? = ? else { return }

# `? else` instead of `map-empty`
# : if true  { {foo: "goo"} } | ? else { {foo: "bar"} } | get foo
# goo
# : if false { {foo: "goo"} } | ? else { {foo: "bar"} } | get foo
# bar

export def run [state: record clip: record] {
    mut state = $state
    match $clip.data {
        # hello
        {op: 10} => {
            $state.heartbeat_interval = $clip.data.d.heartbeat_interval
            $state.last_ack = $clip.id
            $state.last_sent = $clip.id
            $state.authing = null
            return $state
        },
    }

    error make { msg: $"todo ($clip | table -e)" }
}

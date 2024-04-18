#!/usr/bin/env -S nu --stdin

alias and-then = if ($in | is-not-empty)
alias ? = if ($in | is-not-empty) { $in }
alias ?? = ? else { return }

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

def next-message-create [last_id?: string] {
    let params = (flatten-params {"--last-id": $last_id})
    xs ./discord cat ...$params |
    lines | each { from json } | update data { from json } |
    where { |e|
        ($e.topic  == "dispatch") and ($e.data.data.t == "MESSAGE_CREATE")
    } | get 0?
}

def send-message [channel_id: string] {
    let data = $in
    let headers = {
        Authorization: $"Bot ($env.BOT_TOKEN)",
    }
    let url = $"https://discord.com/api/v9/channels/($channel_id)/messages"
    http post --content-type application/json  --headers $headers $url $data
}

def plugin [heart_path] {
    let m = $in
    if $m.content == "./heartbeat status" {
        { content: $"```(open $heart_path | ^cat)```",

            message_reference: { message_id: $m.id },
        } | send-message $m.channel_id
    }
}

def main [path, heart_path] {
    let state = (try { open $path } | ? else { {
        last_id: null,
    } })

    next-message-create $state.last_id | and-then {
        let event = $in
        let m = $event.data.data.d
        let message = {id: $m.id, channel_id: $m.channel_id, content: $m.content}
        $message | plugin $heart_path | cat
        {last_id: $event.id } | save -f $path
    }
}

#!/usr/bin/env -S nu --stdin

alias and-then = if ($in | is-not-empty)

# unfortunately `else` can't be included in the alias
alias ? = if ($in | is-not-empty) { $in }
alias ?? = ? else { return }

def map-values [closure: closure] {
    transpose  | each { update column1 { do $closure } } | transpose --header-row -d
}

export def run-roller [] {
    let last_id = (xs-get-last "plugin.roller.last" | and-then { ["--last-id", $in.id] } | map-empty {[]})
    let actions = (
        xs-cat ...$last_id | where topic == "discord.channel.message" |
        each { |message| $message.data.content | parse-roller | and-then {
                {message: $message, roll: $in}
            }
        }
    )
    $actions | and-then { to json | xs goo put --topic plugin.roller.last }
    $actions | each { |action| {
        content: ($action.roll | bot roll),
        message_reference: { message_id: $action.message.data.id },
        } | send-message $action.message.data.channel_id
    }
}

export def parse-roller [] {
    parse --regex '\./roll (?P<dice>\d+)d(?P<sides>\d+)(?:\+(?P<modifier>\d+))?' | and-then {
        update modifier { if $in == "" { "0" } else { $in } } | map-values { into int } 
    }
}

export def roll [] {
   let roll = $in

   let dice = (random dice --dice $roll.dice --sides $roll.sides)

   mut content = ($dice | each { $"($in) <:nondescript_die:1227997035945267232>" } | str join " + ")

   if $roll.modifier != 0 {
       $content += $" + ($roll.modifier)"
   }

   $content += $" == ($roll.modifier + ($dice | math sum))"
   $content
}

def plugin [state] {

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

def send-message [channel_id: string] {
    let data = $in
    let headers = {
        Authorization: $"Bot ($env.BOT_TOKEN)",
    }
    let url = $"https://discord.com/api/v9/channels/($channel_id)/messages"
    http post --content-type application/json  --headers $headers $url $data
}

def main [path] {
    let state = (try { open $path } | ? else { { 
        last_id: null,
    } })

    let params = (flatten-params {"--last-id": $state.last_id})
    print $params

    let event = (
        xs ./discord cat ...$params |
        lines | each { from json } | update data { from json } |
        where { |e|
            ($e.topic  == "dispatch") and ($e.data.data.t == "MESSAGE_CREATE")
        } | get 0?
        )

    if ($event | is-empty) {
        return 
    }

    let m = $event.data.data.d

    let message = {id: $m.id, channel_id: $m.channel_id, content: $m.content}

    $message.content | parse-roller | and-then {
        let req = $in
        {
            content: ($req | roll),
            message_reference: { message_id: $message.id },
        } | send-message $message.channel_id
    }

    {last_id: $event.id } | save -f $path
}

alias and-then = if ($in | is-not-empty)
alias ? = if ($in | is-not-empty) { $in }
alias ?? = ? else { return }

def build-query [params] {
    $params | columns | each { |x|
        let value = ($params | get $x)
        match ( $value | describe ) {
            "string" => $"($x)=($value)",
            "bool" => (if $value { $x }),
        }
    } | and-then { $"?($in | str join "&")" }
}

def cat [
    store: string
    args
] {
    mut params = {follow: false, tail: false}
    mut i = 0
    while $i < ($args | length) {
        let arg = ($args | get $i)
        match $arg {
            "--last-id" => { 
                $i = $i + 1 
                $params.last_id = ($args | get $i)
            }
            "--follow" => { $params.follow = true }
            "--tail" => { $params.tail = true }
        _ => { print $"unknown argument: ($arg)"; return }

        }
        $i = $i + 1
    }
    let query = (build-query $params)
    let url = $"localhost/($query)"
    curl -sN --unix-socket $"($store)/sock" $url | lines | each { from json }
}


export def --wrapped main [
    store: string
    command: string
    ...rest
] {
    match $command {
        "cat" => { cat $store $rest }
        _ => { print $"unknown command: ($command)" }
    }
}

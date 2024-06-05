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
    print (build-query $params)
}


export def --wrapped main [
    store: string
    command: string
    ...rest
] {
    match $command {
        "cat" => { cat $rest }
        _ => { print $"unknown command: ($command)" }
    }
}

# a module

export alias and-then = if ($in | is-not-empty)
export alias ? = if ($in | is-not-empty) { $in }
export alias ?? = ? else { return }

export def map-values [closure: closure] {
    transpose  | each { update column1 { do $closure } } | transpose --header-row -d
}


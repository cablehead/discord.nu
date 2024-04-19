#!/usr/bin/env -S nu --stdin

use common.nu *
use runner.nu

def parse-sheet [] {
    parse --regex '\./sheet (?P<name>.+)' | get 0?
}

def get-core-sheet [] {
    $in | transpose |
        where column0 in [ name, class, level, xp, hp, ap, dp, stats ] |
        transpose --header-row |
        get 0?
}

def plugin [] {
    $in | parse-sheet | and-then {
        let x = $in
        try { open (("./sheets" | path join $x.name) + ".json") } | and-then {
            let x = $in
            $x | get-core-sheet | table -e -w 40 -t light | ansi strip | $"```\n($in)\n```"
        }
    }
}

def main [state_path] {
    # "./sheet devin" | plugin
    runner run-plugin $state_path { plugin }
}

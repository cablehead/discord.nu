#!/usr/bin/env -S nu --stdin

use xs.nu

export def main [topic: string] {
    xs chomp ./store {|x|
        if $x.content.op == 0 and ($x.content.t | str starts-with "MESSAGE_") {
            $x.content
                | to json -r
                | xs append ./store "03BWV8JG3V64KV3I8KQNLNVNS" --meta {source_id: $x.id}
        }
    }
}

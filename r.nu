#!/usr/bin/env -S nu --stdin

use xs.nu

xs chomp ./store {|x|
    if $x.content.op == 0 and ($x.content.t | str starts-with "MESSAGE_") {
        $x.content | xs append ./store "messages" --meta {source_id: $x.id}
    }
}

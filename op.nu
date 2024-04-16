#!/usr/bin/env -S nu

# https://discord.com/developers/docs/topics/gateway-events

# 1	Heartbeat

# Used to maintain an active gateway connection. Must be sent every
# heartbeat_interval milliseconds after the Opcode 10 Hello payload is received.
# The inner d key is the last sequence number—s—received by the client. If you
# have not yet received one, send null.

export def heartbeat [seqno?: int] {
    {
        "op": 1,
        "d": $seqno,
    }
}

# 2	Identify

# token	string	Authentication token	-
# properties	object	Connection properties	-
# compress?	boolean	Whether this connection supports compression of packets	false
# large_threshold?	integer	Value between 50 and 250, total number of members where the gateway will stop sending offline members in the guild member list	50
# shard?	array of two integers (shard_id, num_shards)	Used for Guild Sharding	-
# presence?	update presence object	Presence structure for initial presence information	-
# intents	integer	Gateway Intents you wish to receive

export def identify [token: string, intents: int] {
    {
        "op": 2,
        "d": {
            token: $token,
            intents: $intents,
            properties: {
                os: (sys | get host.name),
                browser: "discord.nu",
                device: "discord.nu",
            },
        },
    }
}

# 3	Presence Update
# 6	Resume

const API_BASE = "https://discord.com/api/v10"

# Get Global Application Commands
# https://discord.com/developers/docs/interactions/application-commands#get-global-application-commands

export def "app command list" [application_id: string] {
    let headers = {
        Authorization: $"Bot ($env.BOT_TOKEN)",
    }
    let url = $"($API_BASE)/applications/($application_id)/commands"
    http get --headers $headers $url
}

# Get Global Application Command
# https://discord.com/developers/docs/interactions/application-commands#get-global-application-command

# TODO

# Application Command Option Utilities
# https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-type

export def "app command option string" [
    name: string
    description: string
    --required
    --choices: list<string>
] {
    {
        type: 3
        name: $name
        description: $description
        required: $required
        choices: ($choices | each { |x| {name: $x value: $x} })
    }
}

# Create Global Application Command
# https://discord.com/developers/docs/interactions/application-commands#create-global-application-command

export def "app command create" [
    application_id: string
    name: string              # Name of command, 1-32 characters
    description: string       # 1-100 character description for CHAT_INPUT commands
    --options: list<record>   # array of application command option the parameters for the command, max of 25
] {
    let headers = {
        Authorization: $"Bot ($env.BOT_TOKEN)",
    }

    let url = $"($API_BASE)/applications/($application_id)/commands"

    http post --content-type application/json --headers $headers $url {
        name: $name
        type: 1
        description: $description
        options: $options
    }
}

# Create Interaction Response
# https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response
export def "interaction response" [
    interaction_id: string
    interaction_token: string
    content: string
    --type: int = 4
] {
    let url = $"($API_BASE)/interactions/($interaction_id)/($interaction_token)/callback"

    http post --content-type application/json $url {
        type: $type
        data: {
            content: $content
        }
    }
}


# Send Message

export def send-message [channel_id: string] {
    let data = $in
    let headers = {
        Authorization: $"Bot ($env.BOT_TOKEN)",
    }
    let url = $"https://discord.com/api/v10/channels/($channel_id)/messages"
    http post --content-type application/json  --headers $headers $url $data
}

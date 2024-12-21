const API_BASE = "https://discord.com/api/v10"

### App

# Get Current Application
# https://discord.com/developers/docs/resources/application#get-current-application
export def "app get" [application_id?: string] {
  let headers = {
    Authorization: $"Bot ($env.BOT_TOKEN)"
  }
  let url = $"($API_BASE)/applications/@me"
  http get --headers $headers $url
}

# Get Global Application Commands
# https://discord.com/developers/docs/interactions/application-commands#get-global-application-commands
export def "app command list" [application_id: string] {
  let headers = {
    Authorization: $"Bot ($env.BOT_TOKEN)"
  }
  let url = $"($API_BASE)/applications/($application_id)/commands"
  http get --headers $headers $url
}

# Get Global Application Command
# https://discord.com/developers/docs/interactions/application-commands#get-global-application-command
# TODO

# util-for: discord app command create::options
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
    choices: ($choices | each {|x| { name: $x value: $x }})
  }
}

# util-for: discord app command create::options
# https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-type
export def "app command option int" [
  name: string
  description: string
  --required
] {
  {
    type: 4
    name: $name
    description: $description
    required: $required
  }
}
# -- Application Command Option Utilities

# Create Global Application Command
# https://discord.com/developers/docs/interactions/application-commands#create-global-application-command
export def "app command create" [
  application_id: string
  name: string # Name of command, 1-32 characters
  description: string # 1-100 character description for CHAT_INPUT commands
  --options: list<record> # array of application command option the parameters for the command, max of 25
] {
  let headers = {
    Authorization: $"Bot ($env.BOT_TOKEN)"
  }

  let url = $"($API_BASE)/applications/($application_id)/commands"

  http post --content-type application/json --headers $headers $url {
    name: $name
    type: 1
    description: $description
    options: $options
  }
}

### Interaction

# Create Interaction Response
# https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response
export def "interaction response" [
  interaction_id: string
  interaction_token: string
  content: string
  --type: int =4
] {
  let url = $"($API_BASE)/interactions/($interaction_id)/($interaction_token)/callback"

  http post --content-type application/json $url {
    type: $type
    data: {
      content: $content
    }
  }
}

### Channel

# Channel Message Create
# https://discord.com/developers/docs/resources/message#create-message
export def "channel message create" [channel_id: string] {
  let data = $in
  let headers = {
    Authorization: $"Bot ($env.BOT_TOKEN)"
  }
  let url = $"https://discord.com/api/v10/channels/($channel_id)/messages"

  let res = (
    http post
    --full
    --allow-errors
    --content-type application/json
    --headers $headers
    $url
    $data
  )

  if $res.status >= 499 {
    return ( error make { msg: ($res | to json) })
  }

  $res
}

# Channel Thread Create
# https://discord.com/developers/docs/resources/channel#start-thread-without-message
export def "channel thread create" [
  channel_id: string
  name: string
  message_id?: string
] {
  let headers = {
    Authorization: $"Bot ($env.BOT_TOKEN)"
  }

  mut url = $"($API_BASE)/channels/($channel_id)"
  if $message_id != null {
    $url = $url + $"/messages/($message_id)"
  }

  $url = $url + "/threads"

  http post --content-type application/json --headers $headers $url {
    name: $name
    type: 11
  }
}

# Channel Modify
# https://discord.com/developers/docs/resources/channel#modify-channel
export def "channel modify" [
  channel_id: string
]: record -> any {
  let headers = {
    Authorization: $"Bot ($env.BOT_TOKEN)"
  }
  let data = $in
  let url = $"($API_BASE)/channels/($channel_id)"
  http patch --content-type "application/json" --headers $headers $url $data
}

# Channel Thread Join
# https://discord.com/developers/docs/resources/channel#join-thread
export def "channel thread join" [
  channel_id: string
] {
  let headers = {
    Authorization: $"Bot ($env.BOT_TOKEN)"
  }
  let url = $"($API_BASE)/channels/($channel_id)/thread-members/@me"
  http put --full --headers $headers $url ""
}

### Guild

# List Guild Channels
# https://discord.com/developers/docs/resources/guild#get-guild-channels
export def "guild channel list" [guild_id: string] {
  let headers = {
    Authorization: $"Bot ($env.BOT_TOKEN)"
  }
  let url = $"($API_BASE)/guilds/($guild_id)/channels"

  http get --headers $headers $url
}

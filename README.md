## discord.nu

Nushell wrapper for the Discord REST API

### Available commands

#### App

- `discord app command create` _-- [create global application command](https://discord.com/developers/docs/interactions/application-commands#create-global-application-command)_
  - helpers for defining [command options](https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-type):
    - `discord app command option int`
    - `discord app command option string`
- `discord app command list` _-- [get global application commands](https://discord.com/developers/docs/interactions/application-commands#get-global-application-commands)_
- `discord app get` _-- [get current application](https://discord.com/developers/docs/resources/application#get-current-application)_

#### Channel

- `discord channel message create` _-- [channel message create](https://discord.com/developers/docs/resources/message#create-message)_
- `discord channel message list` _-- [get channel messages](https://discord.com/developers/docs/resources/channel#get-channel-messages)_
- `discord channel modify` _-- [channel modify](https://discord.com/developers/docs/resources/channel#modify-channel)_
- `discord channel thread create` _-- [channel thread create](https://discord.com/developers/docs/resources/channel#start-thread-without-message)_
- `discord channel thread join` _-- [channel thread join](https://discord.com/developers/docs/resources/channel#join-thread)_

#### Guild

- `discord guild channel list` _-- [list guild channels](https://discord.com/developers/docs/resources/guild#get-guild-channels)_

#### Interaction

- `discord interaction response` _-- [create interaction response](https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response)_


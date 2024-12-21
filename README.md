## discord.nu

Nushell wrapper for the Discord REST API

### Available commands

#### App

- `discord app command create` _# [Create Global Application Command](https://discord.com/developers/docs/interactions/application-commands#create-global-application-command)_
  - utility commands:
    - `discord app command option int`
    - `discord app command option string`
- `discord app command list` _# [Get Global Application Commands](https://discord.com/developers/docs/interactions/application-commands#get-global-application-commands)_
- `discord app get` _# [Get Current Application](https://discord.com/developers/docs/resources/application#get-current-application)_

#### Channel

- `discord channel message create` _# [Channel Message Create](https://discord.com/developers/docs/resources/message#create-message)_
- `discord channel modify` _# [Channel Modify](https://discord.com/developers/docs/resources/channel#modify-channel)_
- `discord channel thread create` _# [Channel Thread Create](https://discord.com/developers/docs/resources/channel#start-thread-without-message)_
- `discord channel thread join` _# [Channel Thread Join](https://discord.com/developers/docs/resources/channel#join-thread)_

#### Guild

- `discord guild channel list` _# [List Guild Channels](https://discord.com/developers/docs/resources/guild#get-guild-channels)_

#### Interaction

- `discord interaction response` _# [Create Interaction Response](https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response)_


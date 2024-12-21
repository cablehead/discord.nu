## discord.nu

Nushell wrapper for the Discord REST API

### Available commands

# App
- discord app command create # [Create Global Application Command](https://discord.com/developers/docs/interactions/application-commands#create-global-application-command)
  - utility commands:
    - discord app command option int
    - discord app command option string
- discord app command list # [Get Global Application Commands](https://discord.com/developers/docs/interactions/application-commands#get-global-application-commands)
- discord app get # [Get Current Application](https://discord.com/developers/docs/resources/application#get-current-application)

# Channel
- discord channel message create # [Channel Message Create](https://discord.com/developers/docs/resources/message#create-message)
- discord channel modify # [Channel Modify](https://discord.com/developers/docs/resources/channel#modify-channel)
- discord channel thread create # [Channel Thread Create](https://discord.com/developers/docs/resources/channel#start-thread-without-message)
- discord channel thread join # [Channel Thread Join](https://discord.com/developers/docs/resources/channel#join-thread)

# Guild
- discord guild channel list # [List Guild Channels](https://discord.com/developers/docs/resources/guild#get-guild-channels)

# Interaction
- discord interaction response # [Create Interaction Response](https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response)

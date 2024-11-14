def send-message [channel_id: string] {
    let data = $in
    let headers = {
        Authorization: $"Bot ($env.BOT_TOKEN)",
    }
    let url = $"https://discord.com/api/v9/channels/($channel_id)/messages"
    http post --content-type application/json  --headers $headers $url $data
}

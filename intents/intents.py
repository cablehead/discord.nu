import sys

INTENTS = {
    'GUILDS': 1 << 0,
    'GUILD_MEMBERS': 1 << 1,
    'GUILD_MODERATION': 1 << 2,
    'GUILD_EMOJIS_AND_STICKERS': 1 << 3,
    'GUILD_INTEGRATIONS': 1 << 4,
    'GUILD_WEBHOOKS': 1 << 5,
    'GUILD_INVITES': 1 << 6,
    'GUILD_VOICE_STATES': 1 << 7,
    'GUILD_PRESENCES': 1 << 8,
    'GUILD_MESSAGES': 1 << 9,
    'GUILD_MESSAGE_REACTIONS': 1 << 10,
    'GUILD_MESSAGE_TYPING': 1 << 11,
    'DIRECT_MESSAGES': 1 << 12,
    'DIRECT_MESSAGE_REACTIONS': 1 << 13,
    'DIRECT_MESSAGE_TYPING': 1 << 14,
    'MESSAGE_CONTENT': 1 << 15,
    'GUILD_SCHEDULED_EVENTS': 1 << 16,
    'AUTO_MODERATION_CONFIGURATION': 1 << 20,
    'AUTO_MODERATION_EXECUTION': 1 << 21,
    'GUILD_MESSAGE_POLLS': 1 << 24,
    'DIRECT_MESSAGE_POLLS': 1 << 25
}

def get_enabled_intents(intent_value):
    enabled_intents = []
    for intent_name, intent_flag in INTENTS.items():
        if intent_value & intent_flag:
            enabled_intents.append(intent_name)
    return enabled_intents

def main():
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <intent_value>")
        sys.exit(1)

    try:
        intent_value = int(sys.argv[1])
    except ValueError:
        print("Error: Please provide a valid integer for the intent value.")
        sys.exit(1)

    enabled_intents = get_enabled_intents(intent_value)

    if enabled_intents:
        print("Enabled intents:")
        for intent in enabled_intents:
            print(f"- {intent}")
    else:
        print("No intents enabled.")

if __name__ == "__main__":
    main()
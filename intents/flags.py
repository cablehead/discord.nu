import sys

def get_enabled_options(flag_value):
    # Define the application flags
    application_flags = {
        1 << 6: "APPLICATION_AUTO_MODERATION_RULE_CREATE_BADGE",
        1 << 12: "GATEWAY_PRESENCE",
        1 << 13: "GATEWAY_PRESENCE_LIMITED",
        1 << 14: "GATEWAY_GUILD_MEMBERS",
        1 << 15: "GATEWAY_GUILD_MEMBERS_LIMITED",
        1 << 16: "VERIFICATION_PENDING_GUILD_LIMIT",
        1 << 17: "EMBEDDED",
        1 << 18: "GATEWAY_MESSAGE_CONTENT",
        1 << 19: "GATEWAY_MESSAGE_CONTENT_LIMITED",
        1 << 23: "APPLICATION_COMMAND_BADGE",
    }

    # Find enabled options
    enabled_options = [name for value, name in application_flags.items() if flag_value & value]

    return enabled_options


if __name__ == "__main__":
    try:
        flag_value = int(sys.argv[1])
    except ValueError:
        print("Error: Please provide a valid integer for the intent value.")
        sys.exit(1)

    # Get the enabled options
    enabled_options = get_enabled_options(flag_value)

    # Output the result
    if enabled_options:
        print("Enabled Options:")
        for option in enabled_options:
            print(f"- {option}")
    else:
        print("No options are enabled.")

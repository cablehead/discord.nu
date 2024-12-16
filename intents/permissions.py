import sys

PERMISSIONS = {
    'CREATE_INSTANT_INVITE': 1 << 0,
    'KICK_MEMBERS': 1 << 1,
    'BAN_MEMBERS': 1 << 2,
    'ADMINISTRATOR': 1 << 3,
    'MANAGE_CHANNELS': 1 << 4,
    'MANAGE_GUILD': 1 << 5,
    'ADD_REACTIONS': 1 << 6,
    'VIEW_AUDIT_LOG': 1 << 7,
    'PRIORITY_SPEAKER': 1 << 8,
    'STREAM': 1 << 9,
    'VIEW_CHANNEL': 1 << 10,
    'SEND_MESSAGES': 1 << 11,
    'SEND_TTS_MESSAGES': 1 << 12,
    'MANAGE_MESSAGES': 1 << 13,
    'EMBED_LINKS': 1 << 14,
    'ATTACH_FILES': 1 << 15,
    'READ_MESSAGE_HISTORY': 1 << 16,
    'MENTION_EVERYONE': 1 << 17,
    'USE_EXTERNAL_EMOJIS': 1 << 18,
    'VIEW_GUILD_INSIGHTS': 1 << 19,
    'CONNECT': 1 << 20,
    'SPEAK': 1 << 21,
    'MUTE_MEMBERS': 1 << 22,
    'DEAFEN_MEMBERS': 1 << 23,
    'MOVE_MEMBERS': 1 << 24,
    'USE_VAD': 1 << 25,
    'CHANGE_NICKNAME': 1 << 26,
    'MANAGE_NICKNAMES': 1 << 27,
    'MANAGE_ROLES': 1 << 28,
    'MANAGE_WEBHOOKS': 1 << 29,
    'MANAGE_GUILD_EXPRESSIONS': 1 << 30,
    'USE_APPLICATION_COMMANDS': 1 << 31,
    'REQUEST_TO_SPEAK': 1 << 32,
    'MANAGE_EVENTS': 1 << 33,
    'MANAGE_THREADS': 1 << 34,
    'CREATE_PUBLIC_THREADS': 1 << 35,
    'CREATE_PRIVATE_THREADS': 1 << 36,
    'USE_EXTERNAL_STICKERS': 1 << 37,
    'SEND_MESSAGES_IN_THREADS': 1 << 38,
    'USE_EMBEDDED_ACTIVITIES': 1 << 39,
    'MODERATE_MEMBERS': 1 << 40,
    'VIEW_CREATOR_MONETIZATION_ANALYTICS': 1 << 41,
    'USE_SOUNDBOARD': 1 << 42,
    'CREATE_GUILD_EXPRESSIONS': 1 << 43,
    'CREATE_EVENTS': 1 << 44,
    'USE_EXTERNAL_SOUNDS': 1 << 45,
    'SEND_VOICE_MESSAGES': 1 << 46,
    'SEND_POLLS': 1 << 49,
    'USE_EXTERNAL_APPS': 1 << 50
}

def get_enabled_permissions(permission_value):
    """Convert a permission integer to a list of enabled permission names."""
    enabled_permissions = []
    for permission_name, permission_flag in PERMISSIONS.items():
        if permission_value & permission_flag:
            enabled_permissions.append(permission_name)
    return enabled_permissions

def get_permission_value(permission_names):
    """Convert a list of permission names to their combined integer value."""
    permission_value = 0
    invalid_permissions = []

    for name in permission_names:
        name = name.strip().upper()
        if name in PERMISSIONS:
            permission_value |= PERMISSIONS[name]
        else:
            invalid_permissions.append(name)

    return permission_value, invalid_permissions

def print_usage():
    print("Usage:")
    print("  To get permissions from integer:")
    print("    python permissions.py -i <permission_value>")
    print("  To get integer from permissions:")
    print("    python permissions.py -p <permission1> <permission2> ...")
    print("\nAvailable permissions:")
    for perm in sorted(PERMISSIONS.keys()):
        print(f"  {perm}")

def main():
    if len(sys.argv) < 3:
        print_usage()
        sys.exit(1)

    mode = sys.argv[1]

    if mode == "-i":
        try:
            permission_value = int(sys.argv[2])
            enabled_permissions = get_enabled_permissions(permission_value)
            print(" ".join(enabled_permissions))
        except ValueError:
            print("Error: Please provide a valid integer for the permission value.")
            sys.exit(1)

    elif mode == "-p":
        permission_names = sys.argv[2:]
        permission_value, invalid_permissions = get_permission_value(permission_names)

        print(f"\nPermission value: {permission_value}")
        if invalid_permissions:
            print("\nWarning: The following permissions were not recognized:")
            for invalid in invalid_permissions:
                print(f"- {invalid}")

    else:
        print("Error: Invalid mode. Use -i for integer to permissions or -p for permissions to integer.")
        print_usage()
        sys.exit(1)

if __name__ == "__main__":
    main()

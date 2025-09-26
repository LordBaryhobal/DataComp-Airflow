__version__ = "0.1.0"

def get_provider_info():
    return {
        "package-name": "airflow-provider-minecraft",
        "name": "Minecraft",
        "description": "A short description",
        "integrations": [
            {
                "integration-name": "Minecraft",
                "logo": "/minecraft.png",
                "tags": ["service"]
            }
        ],
        "hooks": [  # Connection manager
            {
                "integration-name": "Minecraft RCON",
                "python-modules": ["minecraft_provider.hooks.rcon"]
            }
        ],
        "connection-types": [  # UI connection settings
            {
                "hook-class-name": "minecraft_provider.hooks.rcon.RCONHook",
                "connection-type": "rcon"
            }
        ],
        "notifications": [  # Notifiers
            "minecraft_provider.notifications.minecraft.MinecraftNotifier"
        ],
        "versions": [__version__]
    }
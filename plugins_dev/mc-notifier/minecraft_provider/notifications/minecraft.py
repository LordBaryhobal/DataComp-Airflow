from functools import cached_property
import json
from typing import Optional
from airflow.providers.common.compat.notifier import BaseNotifier
from minecraft_provider.hooks.rcon import RCONHook

class MinecraftNotifier(BaseNotifier):
    template_fields = ("message", "name")

    def __init__(
        self,
        rcon_conn_id: str = "minecraft_rcon_default",
        message: str = "",
        name: Optional[str] = None
    ) -> None:
        super().__init__()
        self.rcon_conn_id: str = rcon_conn_id
        self.message: str = message
        self.name: str = name or "Apache-Airflow"
    
    @cached_property
    def rcon(self) -> RCONHook:
        return RCONHook(rcon_conn_id=self.rcon_conn_id)

    def _build_command(self) -> str:
        return " ".join([
            "tellraw", "@a", json.dumps([
                f"[{self.name}] ",
                self.message
            ])
        ])

    def notify(self, context):
        cmd: str = self._build_command()
        self.rcon.send_command(cmd)


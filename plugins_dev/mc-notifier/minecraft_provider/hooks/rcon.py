import socket
from typing import Optional

from airflow.hooks.base import BaseHook
from minecraft_provider.protocol import Packet, PacketType


class RCONHook(BaseHook):
    conn_name_attr = "rcon_conn_id"
    default_conn_name = "rcon_default"
    conn_type = "rcon"
    hook_name = "Minecraft RCON"

    @classmethod
    def get_ui_field_behaviour(cls) -> dict:
        return {"hidden_fields": ["login", "schema", "extra"], "relabeling": {}}

    def __init__(
        self,
        rcon_conn_id: Optional[str] = None,
        host: str = "",
        port: Optional[int] = None,
        password: Optional[str] = None
    ) -> None:
        super().__init__()
        self.rcon_conn_id: Optional[str] = rcon_conn_id
        self.host: str = host
        self.port: Optional[int] = port
        self.password: Optional[str] = password

        if self.rcon_conn_id is not None:
            conn = self.get_connection(self.rcon_conn_id)
            if not self.host and conn.host:
                self.host = conn.host
            if self.port is None:
                self.port = conn.port
            if self.password is None:
                self.password = conn.password
    
        self.socket: socket.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.connected: bool = False
        self.connect()
    
    def connect(self) -> bool:
        self.socket.connect((self.host, self.port))
        packet: Packet = Packet(
            PacketType.LOGIN,
            self.password.encode() if self.password is not None else b""
        )
        res: Packet = self.send(packet)
        self.connected = res.request_id == packet.request_id
        if not self.connected:
            self.log.error(f"Could not connect to server: {res.payload.decode()}")
        return self.connected
    
    def disconnect(self):
        self.socket.close()
        self.connected = False
    
    def send(self, packet: Packet) -> Packet:
        self.socket.send(packet.to_bytes())
        return Packet.from_bytes(self.socket.recv(4110))
    
    def send_command(self, cmd: str) -> str:
        res: Packet = self.send(Packet(PacketType.COMMAND, cmd.encode()))
        return res.payload.decode()

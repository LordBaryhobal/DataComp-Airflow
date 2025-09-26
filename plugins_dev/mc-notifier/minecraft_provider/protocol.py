from __future__ import annotations

import logging
import random
import socket
import struct
from enum import IntEnum
from typing import Optional


class RCON:
    def __init__(self, host: str, port: int, password: str) -> None:
        self.logger: logging.Logger = logging.getLogger("RCON")
        self.host: str = host
        self.port: int = port
        self.password: str = password
        self.socket: socket.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.connected: bool = False
        self.connect()
    
    def connect(self) -> bool:
        self.socket.connect((self.host, self.port))
        packet: Packet = Packet(PacketType.LOGIN, self.password.encode())
        res: Packet = self.send(packet)
        self.connected = res.request_id == packet.request_id
        if not self.connected:
            self.logger.error(f"Could not connected to server: {res.payload.decode()}")
        return self.connected
    
    def disconnect(self):
        self.socket.close()
        self.connected = False
    
    def send(self, packet: Packet) -> Packet:
        self.socket.send(packet.to_bytes())
        data: bytes = self.socket.recv(4110)
        res: Packet = Packet.from_bytes(data)
        return res
    
    def send_command(self, cmd: str) -> str:
        packet: Packet = Packet(PacketType.COMMAND, cmd.encode())
        res: Packet = self.send(packet)
        return res.payload.decode()


class PacketType(IntEnum):
    OUTPUT = 0
    COMMAND = 2
    LOGIN = 3


class Packet:
    def __init__(self, type: PacketType, payload: bytes, request_id: Optional[int] = None) -> None:
        self.type: PacketType = type
        self.payload: bytes = payload
        self.request_id: int = random.randint(0, 0xffffffff) if request_id is None else request_id

    @staticmethod
    def from_bytes(data: bytes) -> Packet:
        length: int
        rid: int
        type_i: int
        length, rid, type_i = struct.unpack("<III", data[:12])
        packet_type: PacketType = PacketType(type_i)

        return Packet(packet_type, data[12:4 + length - 1], rid)

    def to_bytes(self) -> bytes:
        length: int = 8 + len(self.payload) + 1
        header: bytes = struct.pack("<III", length, self.request_id, self.type)
        pad: bytes = b"\x00"
        return header + self.payload + pad

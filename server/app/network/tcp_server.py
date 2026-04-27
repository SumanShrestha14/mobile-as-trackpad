"""Async TCP server for phone trackpad control."""

from __future__ import annotations

import asyncio
import logging
from typing import Any

from app.config import ServerConfig
from app.network.session import ClientSession
from app.os_control.adapter import OSInputAdapter
from app.protocol.messages import STATEFUL_MESSAGE_TYPES
from app.protocol.parser import Message, ProtocolError, encode_message, parse_message


class TrackpadTCPServer:
    def __init__(self, config: ServerConfig, os_adapter: OSInputAdapter) -> None:
        self._config = config
        self._os = os_adapter
        self._log = logging.getLogger(__name__)

    async def start(self) -> None:
        server = await asyncio.start_server(
            client_connected_cb=self._handle_client,
            host=self._config.host,
            port=self._config.port,
        )
        sockets = server.sockets or []
        endpoints = ", ".join(str(s.getsockname()) for s in sockets)
        self._log.info("Trackpad server listening on %s", endpoints)

        async with server:
            await server.serve_forever()

    async def _handle_client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter) -> None:
        peer = str(writer.get_extra_info("peername"))
        session = ClientSession(peer=peer)
        self._log.info("Client connected: %s", peer)

        try:
            while True:
                try:
                    raw = await asyncio.wait_for(
                        reader.readline(), timeout=self._config.heartbeat_timeout_sec
                    )
                except TimeoutError:
                    await self._send_error(writer, "heartbeat_timeout")
                    break

                if not raw:
                    break

                raw_line = raw.decode("utf-8", errors="replace").strip()
                if not raw_line:
                    continue

                try:
                    msg = parse_message(raw_line)
                except ProtocolError as exc:
                    await self._send_error(writer, str(exc))
                    continue

                should_close = await self._process_message(session, writer, msg)
                if should_close:
                    break
        finally:
            # Ensure no stuck button state remains after an abrupt disconnect.
            self._os.up("left")
            writer.close()
            await writer.wait_closed()
            self._log.info("Client disconnected: %s", peer)

    async def _process_message(
        self, session: ClientSession, writer: asyncio.StreamWriter, msg: Message
    ) -> bool:
        if msg.seq <= session.last_seq and msg.msg_type in STATEFUL_MESSAGE_TYPES:
            self._log.debug("Ignoring stale message seq=%s last_seq=%s", msg.seq, session.last_seq)
            return False

        if msg.msg_type == "HELLO":
            session.hello_received = True
            await self._send(writer, "ACK", {"event": "HELLO"}, seq=msg.seq)
            session.last_seq = msg.seq
            return False

        if msg.msg_type == "AUTH":
            token = str(msg.payload.get("token", ""))
            expected = self._config.auth_token
            if expected and token != expected:
                await self._send_error(writer, "auth_failed", seq=msg.seq)
                return True
            session.authenticated = True
            await self._send(writer, "READY", {"auth": "ok"}, seq=msg.seq)
            session.last_seq = msg.seq
            return False

        if not session.hello_received:
            await self._send_error(writer, "hello_required", seq=msg.seq)
            return False

        if self._config.auth_token and not session.authenticated:
            await self._send_error(writer, "auth_required", seq=msg.seq)
            return False

        if msg.msg_type == "HEARTBEAT":
            await self._send(writer, "ACK", {"event": "HEARTBEAT"}, seq=msg.seq)
        elif msg.msg_type == "MOVE":
            self._os.move(float(msg.payload.get("dx", 0.0)), float(msg.payload.get("dy", 0.0)))
        elif msg.msg_type == "TAP":
            button = str(msg.payload.get("button", "left"))
            clicks = int(msg.payload.get("clicks", 1))
            self._os.tap(button=button, clicks=clicks)
        elif msg.msg_type == "DOWN":
            self._os.down(button=str(msg.payload.get("button", "left")))
        elif msg.msg_type == "UP":
            self._os.up(button=str(msg.payload.get("button", "left")))
        elif msg.msg_type == "SCROLL":
            self._os.scroll(amount=int(msg.payload.get("amount", 0)))
        elif msg.msg_type == "DISCONNECT":
            await self._send(writer, "ACK", {"event": "DISCONNECT"}, seq=msg.seq)
            return True
        else:
            await self._send_error(writer, "unsupported_type", seq=msg.seq)

        session.last_seq = msg.seq
        return False

    async def _send(self, writer: asyncio.StreamWriter, msg_type: str, payload: dict[str, Any], seq: int) -> None:
        writer.write(encode_message(msg_type, payload=payload, seq=seq))
        await writer.drain()

    async def _send_error(self, writer: asyncio.StreamWriter, code: str, seq: int = 0) -> None:
        await self._send(writer, "ERROR", {"code": code}, seq=seq)

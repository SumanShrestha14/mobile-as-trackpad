import asyncio
import json

from app.config import ServerConfig
from app.network.tcp_server import TrackpadTCPServer
from app.os_control.adapter import OSInputAdapter


async def _send_json(writer: asyncio.StreamWriter, frame: dict) -> None:
    writer.write((json.dumps(frame) + "\n").encode("utf-8"))
    await writer.drain()


async def _recv_json(reader: asyncio.StreamReader) -> dict:
    raw = await reader.readline()
    assert raw, "expected response frame but connection was closed"
    return json.loads(raw.decode("utf-8"))


def test_tcp_flow_happy_path_roundtrip() -> None:
    async def scenario() -> None:
        cfg = ServerConfig(
            host="127.0.0.1",
            port=0,
            auth_token="",
            heartbeat_timeout_sec=2.0,
            log_level="INFO",
            dry_run=True,
        )
        server_runtime = TrackpadTCPServer(config=cfg, os_adapter=OSInputAdapter(dry_run=True))
        server = await asyncio.start_server(server_runtime._handle_client, host=cfg.host, port=cfg.port)

        try:
            sock = server.sockets[0]
            port = int(sock.getsockname()[1])
            reader, writer = await asyncio.open_connection("127.0.0.1", port)

            await _send_json(writer, {"type": "HELLO", "seq": 1, "payload": {}})
            hello_ack = await _recv_json(reader)
            assert hello_ack["type"] == "ACK"
            assert hello_ack["payload"]["event"] == "HELLO"

            await _send_json(writer, {"type": "AUTH", "seq": 2, "payload": {"token": ""}})
            ready = await _recv_json(reader)
            assert ready["type"] == "READY"

            await _send_json(writer, {"type": "MOVE", "seq": 3, "payload": {"dx": 10, "dy": 5}})
            await _send_json(
                writer,
                {"type": "TAP", "seq": 4, "payload": {"button": "left", "clicks": 1}},
            )
            await _send_json(writer, {"type": "SCROLL", "seq": 5, "payload": {"amount": -120}})

            await _send_json(writer, {"type": "DISCONNECT", "seq": 6, "payload": {}})
            disconnect_ack = await _recv_json(reader)
            assert disconnect_ack["type"] == "ACK"
            assert disconnect_ack["payload"]["event"] == "DISCONNECT"

            writer.close()
            await writer.wait_closed()
        finally:
            server.close()
            await server.wait_closed()

    asyncio.run(scenario())


def test_tcp_flow_rejects_invalid_auth_token() -> None:
    async def scenario() -> None:
        cfg = ServerConfig(
            host="127.0.0.1",
            port=0,
            auth_token="secret",
            heartbeat_timeout_sec=2.0,
            log_level="INFO",
            dry_run=True,
        )
        server_runtime = TrackpadTCPServer(config=cfg, os_adapter=OSInputAdapter(dry_run=True))
        server = await asyncio.start_server(server_runtime._handle_client, host=cfg.host, port=cfg.port)

        try:
            sock = server.sockets[0]
            port = int(sock.getsockname()[1])
            reader, writer = await asyncio.open_connection("127.0.0.1", port)

            await _send_json(writer, {"type": "HELLO", "seq": 1, "payload": {}})
            _ = await _recv_json(reader)

            await _send_json(writer, {"type": "AUTH", "seq": 2, "payload": {"token": "wrong"}})
            err = await _recv_json(reader)
            assert err["type"] == "ERROR"
            assert err["payload"]["code"] == "auth_failed"

            writer.close()
            await writer.wait_closed()
        finally:
            server.close()
            await server.wait_closed()

    asyncio.run(scenario())

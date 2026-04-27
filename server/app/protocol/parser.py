"""Protocol parsing and validation."""

from __future__ import annotations

import json
from dataclasses import dataclass
from typing import Any

from app.protocol.messages import ALLOWED_MESSAGE_TYPES


class ProtocolError(ValueError):
    """Raised when an incoming protocol frame is invalid."""


@dataclass(slots=True)
class Message:
    msg_type: str
    seq: int
    payload: dict[str, Any]
    session_id: str = ""


def parse_message(raw_line: str) -> Message:
    """Parse and validate a single JSON line message."""
    try:
        raw = json.loads(raw_line)
    except json.JSONDecodeError as exc:
        raise ProtocolError("invalid_json") from exc

    if not isinstance(raw, dict):
        raise ProtocolError("invalid_frame")

    msg_type = raw.get("type")
    if not isinstance(msg_type, str) or msg_type not in ALLOWED_MESSAGE_TYPES:
        raise ProtocolError("invalid_type")

    seq = raw.get("seq", 0)
    if not isinstance(seq, int) or seq < 0:
        raise ProtocolError("invalid_seq")

    payload = raw.get("payload", {})
    if payload is None:
        payload = {}
    if not isinstance(payload, dict):
        raise ProtocolError("invalid_payload")

    session_id = raw.get("session_id", "")
    if session_id is None:
        session_id = ""
    if not isinstance(session_id, str):
        raise ProtocolError("invalid_session")

    return Message(msg_type=msg_type, seq=seq, payload=payload, session_id=session_id)


def encode_message(msg_type: str, payload: dict[str, Any] | None = None, seq: int = 0) -> bytes:
    """Encode an outbound message as a JSON line."""
    frame = {
        "type": msg_type,
        "seq": seq,
        "payload": payload or {},
    }
    return (json.dumps(frame, separators=(",", ":")) + "\n").encode("utf-8")

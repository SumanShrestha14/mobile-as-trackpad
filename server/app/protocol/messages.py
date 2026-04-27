"""Protocol message constants and helpers."""

from __future__ import annotations

ALLOWED_MESSAGE_TYPES = {
    "HELLO",
    "AUTH",
    "READY",
    "MOVE",
    "TAP",
    "DOWN",
    "UP",
    "SCROLL",
    "HEARTBEAT",
    "ACK",
    "ERROR",
    "DISCONNECT",
}

STATEFUL_MESSAGE_TYPES = {"TAP", "DOWN", "UP", "SCROLL", "MOVE"}

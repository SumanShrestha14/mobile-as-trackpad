"""Connection session state."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(slots=True)
class ClientSession:
    peer: str
    authenticated: bool = False
    hello_received: bool = False
    last_seq: int = -1

"""Runtime configuration for the trackpad server."""

from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(slots=True)
class ServerConfig:
    host: str = "0.0.0.0"
    port: int = 8765
    auth_token: str = ""
    heartbeat_timeout_sec: float = 15.0
    log_level: str = "INFO"
    dry_run: bool = False

    @classmethod
    def from_env(cls) -> "ServerConfig":
        """Build config from environment variables."""
        return cls(
            host=os.getenv("TRACKPAD_HOST", "0.0.0.0"),
            port=int(os.getenv("TRACKPAD_PORT", "8765")),
            auth_token=os.getenv("TRACKPAD_AUTH_TOKEN", "").strip(),
            heartbeat_timeout_sec=float(os.getenv("TRACKPAD_HEARTBEAT_TIMEOUT", "15")),
            log_level=os.getenv("TRACKPAD_LOG_LEVEL", "INFO").upper(),
            dry_run=os.getenv("TRACKPAD_DRY_RUN", "false").lower() in {"1", "true", "yes"},
        )

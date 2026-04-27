"""Application entry point."""

from __future__ import annotations

import asyncio
import logging

from app.config import ServerConfig
from app.network.tcp_server import TrackpadTCPServer
from app.os_control.adapter import OSInputAdapter


def main() -> None:
    """Start the trackpad server."""
    config = ServerConfig.from_env()
    logging.basicConfig(
        level=getattr(logging, config.log_level, logging.INFO),
        format="%(asctime)s %(levelname)s %(name)s - %(message)s",
    )

    adapter = OSInputAdapter(dry_run=config.dry_run)
    server = TrackpadTCPServer(config=config, os_adapter=adapter)

    try:
        asyncio.run(server.start())
    except KeyboardInterrupt:
        logging.getLogger(__name__).info("Server stopped by user")


if __name__ == "__main__":
    main()

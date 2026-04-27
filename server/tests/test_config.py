from app.config import ServerConfig


def test_config_defaults() -> None:
    config = ServerConfig.from_env()
    assert config.host
    assert config.port > 0

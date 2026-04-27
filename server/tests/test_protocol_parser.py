import pytest

from app.protocol.parser import ProtocolError, parse_message


def test_parse_valid_message() -> None:
    msg = parse_message('{"type":"MOVE","seq":4,"payload":{"dx":1.5,"dy":-2.0}}')
    assert msg.msg_type == "MOVE"
    assert msg.seq == 4
    assert msg.payload["dx"] == 1.5


def test_parse_rejects_invalid_json() -> None:
    with pytest.raises(ProtocolError):
        parse_message("{bad json}")


def test_parse_rejects_unknown_type() -> None:
    with pytest.raises(ProtocolError):
        parse_message('{"type":"NOPE","seq":1,"payload":{}}')


def test_parse_rejects_non_int_seq() -> None:
    with pytest.raises(ProtocolError):
        parse_message('{"type":"MOVE","seq":"1","payload":{}}')


def test_parse_rejects_non_dict_payload() -> None:
    with pytest.raises(ProtocolError):
        parse_message('{"type":"MOVE","seq":1,"payload":[]}')

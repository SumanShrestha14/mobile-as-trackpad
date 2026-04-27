# 02 Protocol Contract

## Scope
- Define message envelope and event types.
- Add parse and validation pipeline.
- Add error responses for malformed or unsupported messages.

## Tasks
- Define canonical fields: type, session_id, seq, ts, payload.
- Define event set: HELLO, AUTH, READY, MOVE, TAP, DOWN, UP, SCROLL, HEARTBEAT, ERROR, DISCONNECT.
- Add sequence freshness checks.
- Add protocol version field for forward compatibility.

## Exit criteria
- Valid messages parse into typed internal commands.
- Invalid messages are rejected with structured errors.

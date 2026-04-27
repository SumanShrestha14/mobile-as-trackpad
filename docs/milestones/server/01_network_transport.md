# 01 Network Transport

## Scope
- Create TCP listener baseline.
- Define optional WebSocket adapter boundary.
- Add connection lifecycle hooks.

## Tasks
- Implement connection accept loop.
- Add client session registration and teardown.
- Add heartbeat scheduler and timeout handling.
- Add structured connection logs.

## Exit criteria
- Server accepts and manages client connections reliably.
- Disconnects are detected and cleaned up deterministically.

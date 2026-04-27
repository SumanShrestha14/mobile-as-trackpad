# 04 Session Security and Reconnect

## Scope
- Add basic pairing and auth checks.
- Support robust reconnect behavior.

## Tasks
- Add pairing token validation in handshake.
- Reject untrusted clients by default.
- Keep liveness timestamps and enforce heartbeat timeout.
- Define reconnect state reset rules.

## Exit criteria
- Unauthorized clients cannot control the host.
- Reconnected clients return to a clean, known control state.

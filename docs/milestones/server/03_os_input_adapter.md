# 03 OS Input Adapter

## Scope
- Implement adapter boundary between protocol commands and OS input APIs.
- Start with one backend, keep interface extensible.

## Tasks
- Define adapter interface for move, click, down, up, scroll, key actions.
- Add first backend implementation.
- Normalize units and scaling assumptions.
- Add safety guard for stuck button state on disconnect.

## Exit criteria
- Incoming commands map to deterministic desktop actions.
- Disconnect or crash paths release transient button state.

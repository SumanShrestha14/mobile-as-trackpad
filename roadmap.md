# Phone-as-Trackpad Roadmap

## 1. System Overview

This system turns a smartphone into a low-latency trackpad for a desktop computer over the local WiFi network. The mobile app is built in Flutter and is responsible for touch capture, gesture interpretation, user settings, connection state, and transmission of input events. The desktop server is built in Python and is responsible for receiving the event stream, validating the session, translating commands into desktop actions, and injecting mouse or keyboard input into the operating system.

End-to-end flow:
- User touches the phone screen.
- Flutter captures motion, tap, press, and multi-touch patterns.
- The gesture layer classifies the interaction and converts it into a compact control event.
- The networking layer serializes and transmits the event over WiFi.
- The Python server receives the message, checks that the session is valid, and maps the command to a cursor or scroll action.
- The OS control layer applies the action to the desktop pointer.

The system should behave like a trackpad, not like a remote desktop stream. That means the mobile client sends control signals rather than pixel data, and the server treats the latest input state as more important than outdated motion samples.

## 2. Architecture Design

The architecture is intentionally split into a mobile edge and a desktop control core.

Mobile client responsibilities:
- Render the trackpad surface and connection UI.
- Detect gestures such as move, tap, drag, long press, and scroll.
- Apply local smoothing and sensitivity scaling before transmission.
- Maintain the transport session and reconnect when the server becomes unavailable.
- Optionally pair, authenticate, and store the selected desktop host.

Desktop server responsibilities:
- Listen for incoming connections.
- Authenticate the client and establish a session.
- Parse movement and gesture messages.
- Convert protocol events into pointer, click, drag, scroll, and keyboard actions.
- Execute those actions through an OS abstraction layer.

Communication model:
- The mobile client initiates the connection.
- The server accepts one or more sessions depending on the chosen expansion strategy.
- A session remains active through periodic heartbeats.
- If the link drops, the mobile client retries the connection and replays only safe state such as connection metadata, not old motion history.

Text-based architecture diagram:

User touch
  -> Flutter UI surface
  -> Gesture classifier
  -> Smoothing and sensitivity layer
  -> Protocol encoder
  -> WiFi transport
  -> Python socket or WebSocket listener
  -> Session validator
  -> Command parser
  -> OS input adapter
  -> Desktop cursor / scroll / click

Component boundaries:
- UI and gesture logic must not know anything about desktop OS APIs.
- OS control code must not know anything about Flutter widgets.
- The protocol layer must stay transport-neutral so TCP and WebSocket can be compared or swapped without rewriting gesture logic.

## 3. Data Communication Protocol

The protocol must be compact, explicit, debuggable, and safe to extend.

Recommended framing approach for the blueprint:
- Human-readable messages for MVP, preferably JSON.
- A lightweight envelope with fields such as message type, session id, sequence number, timestamp, and payload.
- A transport-agnostic design so the same semantic messages work over TCP or WebSocket.

Core message types:
- HELLO: client announces capability and version.
- AUTH: client proves it is paired or trusted.
- READY: server confirms the session is active.
- MOVE: relative pointer movement.
- TAP: single or double click intent.
- DOWN: press-and-hold or mouse button down.
- UP: release action.
- SCROLL: vertical or horizontal scroll intent.
- HEARTBEAT: keepalive and liveness probe.
- ACK: optional confirmation for stateful actions.
- ERROR: protocol, auth, or runtime failure.
- DISCONNECT: orderly shutdown.

Message design rules:
- MOVE should carry relative deltas, not absolute coordinates, to keep the cursor responsive to different screen sizes.
- Gesture messages should include timing or phase data when needed so the server can distinguish tap, drag, and long press.
- Sequence numbers should increase monotonically so the server can detect duplicates or stale frames.
- The server should ignore out-of-order motion if a newer frame already represents the current state.

Sending frequency:
- Motion events should be coalesced and sent at a controlled rate instead of every raw sensor update.
- A practical control rate should be chosen as a design target, with higher internal sampling allowed on the phone before coalescing.
- Click and drag transitions should be sent immediately because they change interaction state.
- Heartbeats should be periodic and lightweight.

Error handling strategy:
- Malformed message: reject, log, and keep the session alive unless the error is repeated.
- Authentication failure: close the session and require re-pairing.
- Sequence mismatch: ignore stale motion frames and continue from the newest valid state.
- Transport disconnect: pause input transmission and trigger reconnection.
- Unsupported feature: respond with a structured error so the client can downgrade behavior.

## 4. Algorithms and Logic

### 4.1 Cursor movement smoothing

Goal: make the pointer feel stable without becoming sluggish.

Step-by-step logic:
1. Collect raw finger movement deltas from the gesture surface.
2. Reject micro-jitter under a small dead-zone threshold.
3. Compute a running velocity estimate from recent samples.
4. Apply weighted smoothing to reduce abrupt noise.
5. Preserve rapid swipes by increasing gain when velocity rises.
6. Clamp extreme values so a sudden spike does not create a jump.
7. Emit the final relative movement to the transport layer.

Design note:
- The smoothing filter must be light enough that it does not introduce a noticeable cursor lag.

### 4.2 Gesture detection

The mobile side should classify gestures primarily by duration, movement distance, and touch count.

Tap:
- Start contact.
- Track motion and duration.
- If the finger lifts within the tap window and movement stays below the drag threshold, classify as tap.

Drag:
- If movement exceeds the motion threshold while contact remains active, switch to drag mode.
- Emit a button-down event at drag start if the server expects explicit button state.
- Keep sending MOVE events until release.

Long press:
- If the finger remains down past the long-press timeout with limited movement, classify as long press.
- The server can map this to right-click, drag mode, or context-menu intent depending on the UI policy.

Scroll:
- Use a two-finger gesture or a dedicated mode.
- Measure the vertical or horizontal delta of the scrolling finger group.
- Apply acceleration based on swipe speed.

Ambiguity resolution:
- Tap detection wins only if movement remains inside threshold boundaries.
- Drag should override tap as soon as movement becomes intentional.
- Long press should not be triggered if the gesture has already become a drag.

### 4.3 Click recognition timing

Goal: avoid false clicks caused by tiny accidental movement.

Step-by-step logic:
1. Start a candidate tap timer on finger down.
2. Track total displacement from the initial touch point.
3. If displacement stays below the maximum tap radius and the finger lifts before the timeout, classify as click.
4. If the press lasts beyond the timeout without significant movement, classify as long press.
5. If movement exceeds the drag threshold first, cancel the click candidate and switch to drag.

### 4.4 Scroll acceleration

Goal: make slow gestures precise and fast gestures efficient.

Step-by-step logic:
1. Measure scroll delta over time.
2. Estimate gesture velocity.
3. Map low velocity to small scroll output.
4. Multiply output progressively as velocity increases.
5. Cap maximum acceleration to prevent runaway scroll.
6. Reset acceleration quickly when gesture speed slows.

### 4.5 Sensitivity scaling

Goal: let the user adapt the pointer to different screens and preferences.

Step-by-step logic:
1. Read the current user sensitivity setting.
2. Apply the setting to raw deltas or to post-smoothed deltas, depending on the chosen feel.
3. Use one scaling path for motion and a separate scale for scroll if necessary.
4. Store the setting per device profile so the same phone can behave differently on different desktops.

Recommended control behavior:
- Motion sensitivity should remain stable across sessions.
- Scroll sensitivity can be adjusted independently because users often want different scroll feel than pointer feel.

## 5. Flowcharts

### 5.1 App startup and connection

App launch
  -> load settings
  -> check last known host or pairing info
  -> show connection screen
  -> attempt connect
  -> handshake
  -> authenticate
  -> receive READY
  -> enter active trackpad mode
  -> start heartbeat

If connect fails:
  -> show error state
  -> retry or allow manual host entry

### 5.2 Gesture to data transmission

Finger touches screen
  -> gesture candidate created
  -> movement and timing sampled
  -> classify tap / drag / long press / scroll
  -> apply smoothing and scaling
  -> build protocol message
  -> enqueue for transmit
  -> send over WiFi

### 5.3 Server receive to action execution

Message arrives
  -> validate session
  -> parse type and payload
  -> verify sequence / freshness
  -> map to desktop action
  -> call OS input adapter
  -> apply cursor / click / scroll / key action
  -> optionally send ACK or state update

### 5.4 Reconnection handling

Transport interrupted
  -> pause sending new control frames
  -> preserve user interaction state locally where safe
  -> start reconnect timer
  -> retry connection with backoff
  -> resend HELLO and AUTH
  -> server confirms READY
  -> resume live input

## 6. Networking Strategy

### TCP vs WebSocket

TCP strengths:
- Simple ordered delivery.
- Good fit for low-level control messages.
- Easy to implement in both Flutter and Python.

TCP weaknesses:
- Requires more care around message framing.
- Less convenient if a later browser-based client is desired.

WebSocket strengths:
- Built-in message framing.
- Easier keepalive semantics.
- Better interoperability with proxy-based or web-adjacent setups.

WebSocket weaknesses:
- Adds protocol overhead compared with a raw socket.
- Slightly more abstraction than the simplest possible TCP design.

Recommendation for this roadmap:
- Treat TCP as the baseline MVP transport because this is a local, performance-sensitive control system.
- Keep the protocol transport-neutral so WebSocket can become an alternate backend later if interoperability becomes more important than minimality.

### Connection lifecycle

Connect:
- Mobile discovers or enters the server address.
- Client opens the transport.
- Client sends HELLO and AUTH.
- Server validates and replies READY.

Maintain:
- Heartbeats keep both sides aware that the link is alive.
- The server may track the last-seen sequence number and client liveness.
- The mobile client suppresses old motion if the network stalls.

Disconnect:
- Either side can send DISCONNECT.
- The server clears transient input state such as pressed buttons if the session ends unexpectedly.
- The client returns to connection mode and offers retry.

### Latency, loss, and reconnection

- Cursor motion should be treated as best-effort latest state.
- Clicks, button-down, and button-up transitions must be preserved reliably.
- If packets are delayed, the client should favor the newest motion instead of replaying old deltas.
- If the connection is lost, the client should reconnect automatically using short backoff intervals at first, then longer ones.
- On reconnection, the session should re-authenticate and reset transient motion state.

## 7. Required Tools and Packages

### Flutter packages

- Flutter framework gesture and UI APIs for the trackpad surface, buttons, status panels, and settings.
- Dart socket or WebSocket support for transport.
- State management only if connection and gesture state become complex enough to justify it.
- Optional discovery support if LAN discovery is added later.

What each category is for:
- Gesture and UI APIs: capture touch interaction and display connection state.
- Socket support: send low-latency input frames.
- State management: keep UI, settings, and transport state in sync.
- Discovery support: find the desktop server automatically on the local network.

### Python libraries

- socket or websockets for network handling.
- threading or asyncio for concurrent receive, dispatch, and keepalive work.
- pyautogui or pynput for OS-level mouse and keyboard injection.
- logging for diagnostics and session tracing.

What each category is for:
- Network library: receive and parse control messages.
- Concurrency primitives: keep input handling responsive while listening for new frames.
- Input injection library: translate protocol events into desktop actions.
- Logging: diagnose latency, pairing, and control errors.

### Optional enhancements

- TLS for encrypted transport if the threat model requires more than plain local-network trust.
- mDNS or Bonjour for automatic LAN discovery.
- Persistent pairing storage for trusted devices.
- Structured logs and metrics for tuning latency and gesture quality.

## 8. Performance Optimization Plan

Minimize latency:
- Coalesce pointer movement before sending.
- Avoid unnecessary acknowledgements for high-frequency motion.
- Keep protocol frames small.
- Use a dedicated input pipeline so gesture classification does not block UI rendering.

Avoid jittery movement:
- Apply dead zones to micro-movements.
- Smooth pointer deltas with a lightweight filter.
- Preserve velocity when the user intentionally swipes fast.
- Keep motion output consistent even if sampling intervals vary slightly.

Rate limiting vs real-time streaming:
- Real-time streaming gives the best feel but can flood the network if every raw event is transmitted.
- Rate limiting reduces traffic and server work but can make motion feel less immediate.
- The recommended compromise is local high-frequency sampling with network-side event coalescing and a bounded transmit rate.

## 9. Security Considerations

Prevent unauthorized access:
- Require a pairing code, token, or first-run approval before the desktop accepts control.
- Reject unknown devices by default.
- Allow the desktop to expose control only on the local network interface unless the user explicitly changes this.

Basic authentication design:
- A short-lived token or pairing secret is sufficient for MVP.
- The token should be exchanged during the handshake and never treated as a permanent password if a better pairing flow is added later.

Local network risks:
- Anyone on the same LAN may be able to probe the service if it is unauthenticated.
- A compromised phone on the same network can send hostile control commands if pairing is weak.
- The roadmap should therefore treat auth as mandatory rather than optional.

## 10. Scalability and Future Expansion

Keyboard input:
- Extend the protocol with key down, key up, shortcut, and modifier state events.
- Reuse the same session and transport layer.

Multi-device control:
- Let one desktop accept multiple paired clients.
- Use session IDs and device labels so the server can distinguish controllers.
- Define a conflict policy if two devices try to control the pointer at once.

Bluetooth fallback:
- Keep the command protocol independent of transport so Bluetooth can be added as another carrier later.
- The gesture and OS layers should not care which link delivers the message.

Cross-platform desktop support:
- Add an OS adapter interface with separate backends for Windows, macOS, and Linux.
- Preserve the same protocol and session model across platforms.

## 11. Development Phases

### MVP

- Manual server IP entry.
- Basic connection and handshake.
- Relative cursor movement.
- Tap click.
- Drag.
- Scroll.
- Heartbeat and reconnect.
- Minimal settings for sensitivity.

### Stable version

- Improved gesture classification.
- Stronger smoothing and tuning controls.
- Pairing and authentication.
- Better error states and diagnostics.
- Session recovery and safer transient-state reset.

### Advanced version

- Keyboard shortcuts.
- LAN discovery.
- Multi-device support.
- Optional WebSocket backend.
- Bluetooth fallback exploration.
- Cross-platform OS adapter expansion.

## 12. Final Output Rules

This roadmap is intentionally designed as a build-ready blueprint rather than code. It should guide implementation decisions, module boundaries, protocol semantics, and test planning without embedding source code or API stubs.

Acceptance criteria for the roadmap:
- Every major subsystem is named and scoped.
- The gesture and networking logic are described at algorithm level.
- The transport choice is justified and transport-neutral enough to evolve.
- The phases are incremental and map cleanly to an implementation sequence.
- The document remains readable as an architecture reference for both mobile and server development.
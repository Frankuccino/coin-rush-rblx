# DOMAIN.md

# 🎮 Coin Rush — Domain Design

This document defines the **runtime domain model** of Coin Rush.

It describes how gameplay systems, services, and data flow interact inside the game world.

It is not concerned with tooling or development workflow — only with **how the game behaves at runtime**.

---

# 🧭 Core Domain Concept

Coin Rush is a **round-based competitive collection game**.

Players:

1. Enter a lobby
2. Wait for a match to start
3. Collect coins during a timed round
4. Get ranked based on performance
5. Return to lobby

---

# 🔁 Game Loop Domain State Machine

The entire game revolves around a deterministic state machine:

```text
LOBBY
  ↓
COUNTDOWN
  ↓
ACTIVE ROUND
  ↓
RESULTS
  ↓
LOBBY
```

---

## State: LOBBY

### Responsibility

Wait for minimum players and prepare match start.

### Rules

* Players spawn in lobby area
* No coin interactions are active
* UI shows waiting state
* System checks player count periodically

### Exit Condition

* `PlayerCount >= MIN_PLAYERS`

Triggers transition → COUNTDOWN

---

## State: COUNTDOWN

### Responsibility

Prepare players and transition into gameplay.

### Rules

* 5-second countdown
* UI updates every second
* Players are positioned in arena spawn points
* Lighting transitions to match atmosphere
* Countdown SFX plays

### Exit Condition

* Countdown reaches 0

Triggers transition → ACTIVE ROUND

---

## State: ACTIVE ROUND

### Responsibility

Core gameplay loop.

### Rules

* Coins spawn periodically in arena
* Players collect coins via touch validation
* Score updates in real-time
* Timer counts down (60 seconds)
* VFX and SFX triggered on collection

### Exit Condition

* Round timer reaches 0

Triggers transition → RESULTS

---

## State: RESULTS

### Responsibility

Display outcomes and persist data.

### Rules

* Players are ranked by coins collected
* UI displays leaderboard
* Winner effects triggered
* Chat announcement sent
* Data saved to persistence layer

### Exit Condition

* Intermission timer ends

Triggers transition → LOBBY

---

# 🧩 Domain Services

Each service owns a **single responsibility within the game world**.

---
 
## 🧠 GameService (State Machine Controller)

### Responsibility

Owns and controls the entire game loop state machine.

### Owns:

* Current game state
* State transitions
* Round lifecycle timing

### Emits:

* `StateChanged(state)`
* `RoundStarted`
* `RoundEnded`

---

## 🪙 CoinService

### Responsibility

Manages all coin lifecycle and collection logic.

### Owns:

* Coin spawning
* Coin validation
* Coin collection rules

### Emits:

* `CoinSpawned`
* `CoinCollected(player, amount)`

---

## 👤 PlayerService

### Responsibility

Tracks player participation in game rounds.

### Owns:

* Player join/leave state
* Lobby vs active round status

### Emits:

* `PlayerJoined`
* `PlayerLeft`

---

## 💾 PlayerDataService

### Responsibility

Persistent player progression.

### Owns:

* Total coins earned
* Best round score
* Inventory / unlocks

### Uses:

* ProfileStore

---

## 🖥️ UIService (Client)

### Responsibility

Reactive UI rendering based on game state.

### Reacts to:

* Game state changes
* Score updates
* Timer updates

### Does NOT:

* Own game logic
* Validate gameplay events

---

## 🎨 VFXService (Client)

### Responsibility

Visual feedback system.

### Handles:

* Coin pickup effects
* Round transitions
* Winner effects

---

## 🔊 SoundService (Client)

### Responsibility

Audio feedback system.

### Handles:

* Coin collection sounds
* Countdown ticks
* Round start/end audio

---

# 🔄 Data Flow Model

## Coin Collection Flow

```text
Player touches coin
        ↓
CoinService validates distance + state
        ↓
Server awards coins
        ↓
PlayerDataService updates profile
        ↓
CoinService emits event
        ↓
UIService updates HUD (client)
        ↓
VFXService plays effect (client)
```

---

## Round Start Flow

```text
GameService → Countdown ends
        ↓
Teleport players to arena
        ↓
CoinService activates spawning
        ↓
UIService updates state
        ↓
Sound/VFX systems trigger transitions
```

---

## Round End Flow

```text
GameService timer ends
        ↓
Freeze coin interactions
        ↓
Compute rankings
        ↓
PlayerDataService persists results
        ↓
UIService shows leaderboard
        ↓
Sound/VFX play results sequence
```

---

# 🧱 Architectural Constraints

These rules define system boundaries:

---

## 1. Server owns truth

* Scores
* Coin collection
* Round state
* Player data

Client is always reactive.

---

## 2. Client is presentation only

* UI rendering
* VFX
* Sound
* Input feedback

No gameplay validation.

---

## 3. Services are isolated

No service directly modifies another service’s internal state.

Communication happens via:

* Signals
* Events
* Explicit APIs

---

## 4. Game state is centralized

Only `GameService` controls:

* Round flow
* State transitions
* Timing

---

# 📦 Domain Boundaries

## Server Domain

* GameService
* CoinService
* PlayerService
* PlayerDataService

## Client Domain

* UIService
* VFXService
* SoundService

## Shared Domain

* Constants
* Types
* Utility functions

---

# 🧭 Design Philosophy

Coin Rush is designed around:

* Deterministic game loops
* Explicit state transitions
* Server-authoritative logic
* Reactive client systems
* Modular service boundaries

The goal is to avoid "script sprawl" and instead build a **system of interacting domains**, not isolated scripts.

---

# 🚀 Future Extensions

This domain model supports:

* Coin variants (gold, rare, multiplier)
* Power-ups (speed, magnet, boost)
* Teams or factions
* Cosmetics system
* Shop + monetization systems
* Seasonal events

All extensions should integrate into existing services rather than bypassing them.

---

# 🧠 Summary

Coin Rush is not just a game loop.

It is a structured system of:

* State-driven gameplay
* Service-oriented architecture
* Server-authoritative logic
* Reactive client presentation

This document defines the **runtime truth of the game world**.


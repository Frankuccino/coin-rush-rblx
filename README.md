# Coin Rush 🪙

A production-grade Roblox multiplayer game built with **Rojo**, **Knit**, **Wally**, **Rokit**, and modern **Luau** tooling.

Coin Rush is a round-based arcade game where players compete to collect the most coins before the timer expires. The project serves as both a playable game and a showcase of professional Roblox engineering practices, including service-oriented architecture, state machines, data persistence, client-server authority, and external development tooling.

---

# 🚀 Development Workflow

This project uses a modern Roblox development stack optimized for **Neovim**, external tooling, and source-controlled development.

## Toolchain

Managed via Rokit to ensure consistent versions across contributors and environments.

### Core Tools

* **Rojo** — Syncs the filesystem with Roblox Studio.
* **Wally** — Package and dependency management.
* **StyLua** — Automatic code formatting.
* **Selene** — Static analysis and linting.
* **Luau LSP** — Autocomplete, type checking, hover docs, and diagnostics.

### Key Benefits

* Source-controlled development
* Type-safe Luau
* Consistent formatting across the codebase
* Real-time Roblox API autocomplete
* Fast iteration through Rojo live sync
* Production-ready project structure

---

# 📦 Installation

## Prerequisites

Install the Roblox development toolchain:

```bash
# Install Rokit
curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash

# Install tools globally
rokit add --global rojo-rbx/rojo
rokit add --global UpliftGames/wally
rokit add --global JohnnyMorganz/StyLua
rokit add --global Kampfkarren/selene
rokit add --global JohnnyMorganz/luau-lsp
```

Verify installation:

```bash
rojo --version
wally --version
stylua --version
selene --version
luau-lsp --version
```

---

## Clone Repository

```bash
git clone <repository-url>
cd coin-rush
```

## Install Dependencies

```bash
wally install
```

## Start Rojo

```bash
rojo serve default.project.json
```

Open Roblox Studio → **Plugins → Rojo → Connect**

Your local files are now synchronized with Studio.

---

# 🏗️ Architecture

Coin Rush follows a **service-oriented architecture** built on the Knit framework.

The game loop is managed through a finite state machine:

```text
Lobby
  ↓
Countdown
  ↓
Active Round
  ↓
Results
  ↓
Lobby
```

This pattern mirrors the architecture used in many competitive multiplayer Roblox experiences.

---

# 🎮 Gameplay Features

### Round-Based Gameplay

* Automated lobby management
* Countdown system
* Timed coin collection rounds
* Results and winner announcements

### Progression

* Total coins earned
* Best round score
* Persistent player profiles
* Future cosmetic unlocks

### Monetization

* 2× Coins Gamepass
* Coin Magnet Gamepass
* MarketplaceService integration

### Networking

* Server-authoritative coin validation
* RemoteEvents for client updates
* Optimized client-server communication

---

# 🧩 Core Services

## Server Services

### GameService

Owns the master game state machine.

Responsibilities:

* Lobby management
* Round lifecycle
* Countdown handling
* State transitions
* Match timing

### CoinService

Handles all coin-related gameplay.

Responsibilities:

* Coin spawning
* Coin tracking
* Collection validation
* Score calculation
* Coin respawning

### PlayerDataService

Wraps ProfileStore and persistent player progression.

Responsibilities:

* Data loading and saving
* Coin totals
* Best scores
* Cosmetic ownership
* Gamepass tracking

---

## Client Controllers

### UIController

Responsible for all user interface updates.

Features:

* Lobby player count
* Round timer
* Current score
* Results screen
* Winner announcements

### VFXController

Handles client-side visual feedback.

Features:

* Coin collection effects
* Round start effects
* Victory effects
* UI animations

### SoundController

Manages local audio playback.

Features:

* Coin collection sounds
* Countdown beeps
* Background music
* Round-end fanfare

---

# 🏛️ Roblox Services Used

| Service            | Purpose                     |
| ------------------ | --------------------------- |
| Players            | Player lifecycle management |
| RunService         | Timers and coin animation   |
| TweenService       | UI and world animations     |
| DataStoreService   | Persistent progression      |
| MarketplaceService | Gamepasses and monetization |
| RemoteEvents       | Client-server communication |
| UserInputService   | Input handling              |
| SoundService       | Audio management            |
| Lighting           | Dynamic atmosphere effects  |
| CollectionService  | Coin tagging and queries    |
| TextChatService    | Winner announcements        |
| Debris             | Temporary VFX cleanup       |

---

# 📁 Project Structure

```text
src
├── server
│   └── services
│       ├── GameService.lua
│       ├── CoinService.lua
│       └── PlayerDataService.lua
│
├── client
│   └── controllers
│       ├── UIController.lua
│       ├── VFXController.lua
│       └── SoundController.lua
│
└── shared
    └── modules
```

---

# 🛠️ Configuration

## `.luaurc`

Defines Luau strict mode and path aliases.

```json
{
  "languageMode": "strict",
  "aliases": {
    "Shared": "src/shared",
    "Server": "src/server",
    "Client": "src/client"
  }
}
```

## `selene.toml`

Roblox-aware linting configuration.

```toml
std = "roblox"
```

## `stylua.toml`

Code formatting rules.

```toml
column_width = 100
line_endings = "Unix"
indent_type = "Tabs"
indent_width = 4
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
```

---

# ✅ Code Quality

Format the project:

```bash
stylua .
```

Run static analysis:

```bash
selene src
```

The project uses:

* Strict Luau typing
* Roblox-aware linting
* Automatic formatting
* Modular architecture
* Service-oriented design

---

# 🎯 Learning Objectives

Coin Rush is intentionally designed to exercise nearly every major Roblox system while remaining achievable for a solo developer.

This project demonstrates:

* Production-grade Roblox architecture
* State machine design
* Client-server authority patterns
* Persistent data management
* Real-time multiplayer gameplay
* Modern Roblox tooling
* Professional software engineering workflows

---

# 🚧 Planned Features

* Coin rarity system
* Power-ups
* Cosmetic shop
* Daily rewards
* Achievements
* Seasonal events
* Additional arenas
* Matchmaking improvements
* Analytics integration

---

# 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

Copyright (c) 2026 Frank Angelo Malubag

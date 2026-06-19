# PROJECT.md

# COINRUSH

A Roblox game development project built with a professional software engineering workflow rather than a Roblox Studio-first workflow.

The primary objective of this project is not merely to ship a Roblox game, but to explore how modern software engineering practices, tooling, architecture, and workflows can be applied to Roblox development.

This project serves as an experiment in building Roblox experiences using practices commonly found in modern web, backend, and game development environments.

---

# Vision

Create a Roblox game using a scalable architecture that prioritizes:

* Maintainability
* Developer experience
* Source control
* Automation
* Reusability
* Long-term scalability

The game itself may evolve over time, but the engineering standards and workflow are considered first-class concerns.

---

# Core Philosophy

## Development Workflow Matters

Historically, much of Roblox development has been performed directly inside Roblox Studio.

While Studio is an excellent editor for scene creation and testing, large projects can become difficult to maintain when logic, assets, and workflows are tightly coupled to the editor.

This project adopts a code-first workflow.

Development occurs primarily inside Neovim, with Roblox Studio serving as the runtime and visual editor.

---

## Professional Engineering Practices

This repository follows principles commonly used in professional software development:

* Git version control
* Feature-based architecture
* Modular code organization
* Dependency management
* Linting
* Formatting
* Reproducible environments
* CI/CD readiness

---

## Incremental Complexity

The project intentionally starts simple.

Systems should only become more complex when complexity is justified.

Prefer:

* Simple solutions
* Clear abstractions
* Reversible decisions

Avoid premature optimization.

---

# Current Toolchain

## Editor

* Neovim

Primary development environment.

---

## Source Synchronization

### Rojo

Synchronizes local source files with Roblox Studio.

Benefits:

* Real file system access
* Git compatibility
* Modular project structure

---

## Package Management

### Wally

Manages third-party Roblox dependencies.

Examples:

* Knit
* Promise
* Signal
* ProfileStore

---

## Toolchain Manager

### Rokit

Installs and manages Roblox development tools.

Current tools include:

* Rojo
* Wally
* Stylua
* Selene
* Luau-LSP

---

## Formatting

### StyLua

Provides automatic code formatting.

---

## Linting

### Selene

Provides static analysis and code quality checks.

---

## Language Server

### Luau-LSP

Provides:

* Autocomplete
* Diagnostics
* Type checking
* Navigation

inside Neovim.

---

## Source Control

### Git + GitHub

All project changes are tracked through Git.

Development should occur through small, meaningful commits.

---

# Planned Architecture

## Server Framework

### Knit

Will be used to organize game systems into services and controllers.

Examples:

* PlayerService
* CurrencyService
* InventoryService
* DataService

---

## Async Operations

### Promise

Will be used for asynchronous workflows.

Examples:

* Data loading
* Data saving
* Matchmaking
* Remote communication

---

## Event Communication

### Signal

Will be used for loosely coupled communication between systems.

Examples:

* Item awarded
* Quest completed
* Currency changed

---

## Persistent Data

### ProfileStore

Will manage player data.

Examples:

* Progression
* Currency
* Inventory
* Unlocks

---

## UI Framework

### React Lua (Roact)

Planned UI framework.

Goals:

* Component-driven interfaces
* Reusable UI
* Predictable state flow

---

## State Management

### Charm

Planned reactive state management solution.

Goals:

* Shared state
* Reactive updates
* Clean UI architecture

---

# Architectural Principles

## Separation of Concerns

UI, state, networking, and game logic should remain independent whenever possible.

---

## Composition Over Duplication

Reusable systems should be preferred over duplicated logic.

---

## Feature-Oriented Design

Related functionality should remain grouped together.

Example:

Inventory/

* UI
* Logic
* State
* Networking

instead of scattering related code throughout the project.

---

## Agent-Agnostic Development

Project documentation should contain enough context that:

* Future contributors
* AI assistants
* Future versions of the author

can understand the project's goals and architecture without relying on external conversations.

Documentation is considered part of the codebase.

---

# Development Workflow

1. Write code in Neovim
2. Format with StyLua
3. Lint with Selene
4. Sync using Rojo
5. Test inside Roblox Studio
6. Commit with Git
7. Push to GitHub

---

# Current Status

Current phase:

Foundation and tooling.

Objectives:

* Establish development workflow
* Finalize project architecture
* Configure dependencies
* Prepare UI framework
* Prepare data architecture

Gameplay implementation remains secondary until the development foundation is complete.

---

# Long-Term Goal

Develop Roblox projects with the same level of engineering discipline applied to modern software systems.

The success of this project is measured not only by the final game but also by the quality of the architecture, workflow, and development practices used to build it.


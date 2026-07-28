# Game Design Document: Chicken Chaos

Design and build a polished, replayable 2D pixel art multiplayer party game where three chickens compete on a farm to collect worms while avoiding AI hunters and sabotaging each other.

## Design Analysis & Suggested Improvements

After analyzing the core concept, the vision is strong and highly aligned with successful indie party games. However, to ensure the scope remains small and the gameplay stays engaging, I've identified a few design areas that could be improved:

1. **Match Duration:** 7-10 minutes is quite long for a chaotic party game (which typically run 2-5 minutes per round). **Suggestion:** Reduce the match time to **3-5 minutes**. This keeps the energy high, reduces fatigue, and encourages players to immediately say "just one more round."
2. **Sabotage Details:** To make pecking impactful without being frustrating, pecking should cause a brief "stun" (1 second) and make the victim drop a percentage of their collected worms, which scatter on the ground.
3. **Catch-up Mechanic:** Party games thrive on close matches. **Suggestion:** Golden worms have a slightly higher chance of spawning closer to the player currently in last place, or the player in first place emits a subtle "smell" trail that hunters are slightly more likely to follow.
4. **Hunter Scaling:** Instead of complex AI behavior changes, difficulty can naturally increase by gradually spawning *more* hunters as the timer ticks down, and slightly increasing their patrol speed.
5. **Multiplayer Scope:** You mentioned "no complicated networking architecture". To strictly adhere to this while keeping it a "multiplayer party game", we have two paths:
   - **Path A (Local Multiplayer):** Shared screen. Players use different keyboard keys (WASD, Arrows, IJKL) or connected gamepads. Zero networking required.
   - **Path B (Simple WebSockets):** A basic Node.js/Socket.io relay server where players join via room codes on their phones/browsers.
   *I highly recommend Path A for Version 1 to guarantee a tight, polished loop without netcode headaches.*

---

## User Review Required

> [!IMPORTANT]
> **Multiplayer Architecture**
> Please confirm if you want **Local Multiplayer** (shared screen, single keyboard/multiple gamepads) or **Simple Online Multiplayer** (using web sockets). I recommend Local for V1 to keep the scope as small as possible.

> [!WARNING]
> **Match Duration**
> Are you okay with reducing the match time to 3-5 minutes to increase the frantic pace and replayability?

> [!TIP]
> **Game Engine**
> I propose using **Phaser 3 (JavaScript/HTML5)** combined with **Vite**. It is the industry standard for 2D web games, handles pixel art scaling perfectly, and has built-in arcade physics for collisions and movement.

---

## Open Questions

1. **Art Assets:** Do you have existing pixel art assets we should use, or should I generate placeholder assets (colored squares/simple sprites) that you can replace later?
2. **Dynamic Events:** Should dynamic events be completely randomized, or happen at specific timestamps (e.g., the Tractor always sweeps at the 2-minute mark)?

---

## Architecture Recommendation

- **Engine:** Phaser 3 (Lightweight, robust 2D framework)
- **Build Tool:** Vite (Fast bundling and hot-reloading)
- **Language:** JavaScript / TypeScript (TypeScript is recommended for autocomplete and maintaining game state, but Vanilla JS is fine if you prefer).
- **State Management:** A centralized `GameState` class to track scores, timers, and active events.
- **Physics:** Phaser's built-in Arcade Physics (perfect for top-down collision and movement).

---

## Development Milestones

### Milestone 1: Project Setup & Core Movement
- Initialize Vite + Phaser 3 project.
- Create the main game scene and basic map boundaries.
- Implement player movement (3 players, local controls).
- Add simple collision with world bounds.

### Milestone 2: The Worm Economy
- Implement worm spawning system (random locations, regular vs. golden).
- Add player collision with worms (collection).
- Implement basic score tracking and UI.

### Milestone 3: AI Hunters
- Implement the Hunter entity.
- Add basic patrol state.
- Add vision cone / detection logic.
- Add chase state and "caught" penalty (e.g., losing worms or respawning).

### Milestone 4: Interaction & Hiding
- Implement the "Peck" mechanic (stun + drop worms).
- Add hiding zones (tall grass/cornfields) that change player opacity and break hunter line-of-sight.

### Milestone 5: Polish & Dynamic Events
- Implement a 3-minute match timer and endgame screen.
- Add 1-2 dynamic events (e.g., Rain slowing movement, or Tractor sweeping the map).
- Add basic sound effects and placeholder music.
- Polish animations and visual feedback.

---

## Verification Plan

### Automated Tests
- Given the visual nature of the game, automated tests will be minimal. We will rely on linting (ESLint) to catch syntax errors.

### Manual Verification
- Run the Vite dev server and physically playtest the movement, collisions, and hunter AI.
- Test edge cases (e.g., two players pecking each other simultaneously, hunters losing sight in bushes).

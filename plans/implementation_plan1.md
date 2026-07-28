# Game Design Document: Chicken Gang

Design and build a polished, replayable 2D pixel art multiplayer party game where three chickens compete on a farm to collect worms while avoiding AI hunters and sabotaging each other. 

*This design is derived directly from the provided HTML proof of concept and adapted for the Godot Engine.*

---

## Gameplay & Mechanics extracted from Prototype

The gameplay loop closely follows the HTML prototype to preserve its chaotic and light-hearted feel.

1. **Match Duration:** 3 minutes (180 seconds).
2. **The Worm Economy:**
   - Normal Worms: +1 point.
   - Golden Worms: +5 points (10% spawn chance).
   - Spawn Rate: Every 2 seconds.
3. **Player Interactions (Dash/Peck):**
   - Players can dash (Spacebar).
   - Dash has a 3-second cooldown and provides a massive speed boost (3.5x for 0.25s).
   - Hitting another chicken while dashing **stuns them for 2.0 seconds**, makes them drop 2 worms (which scatter), and deducts 2 points.
   - Visual/Juice: Screen shake and dust particles on dash/hit.
4. **Hunters (AI):**
   - Patrol randomly.
   - Vision Radius: 220px. They detect unhidden chickens within this radius.
   - If spotted, Hunters chase the chicken.
   - If caught: The chicken loses 5 points, is stunned for 2.5 seconds, and the hunter bounces away.
   - Difficulty Scaling: A second Hunter spawns at the 1:30 mark (halfway through the match).
5. **Hiding & Stealth:**
   - Bushes and Cornfields act as hiding spots.
   - Entering a hiding spot makes the chicken semi-transparent (40% opacity) and makes them invisible to Hunters.
6. **Juice & Feel:**
   - Camera tracking with smooth lerping.
   - Screen shake on impacts.
   - Floating "+1" / "-2" score popups.
   - Y-sorting for a 2.5D top-down perspective.

---

## Architecture: Godot Engine

The production implementation will use **Godot Engine** (GDScript), as it is excellent for 2D pixel art games, provides built-in Y-sorting, kinematic body physics, and UI tools.

- **Engine:** Godot 4.x
- **Language:** GDScript
- **Physics:** `CharacterBody2D` for Chickens and Hunters. `Area2D` for Worms, Bushes, and Hitboxes/Hurtboxes.
- **Node Structure:**
  - `GameManager` (Autoload): Tracks match time, overall score, and handles win state.
  - `Chicken` (Scene): State machine for Idle, Move, Dash, and Stunned states.
  - `Hunter` (Scene): State machine for Patrol and Chase states. Uses `Area2D` for the vision radius.
  - `Worm` (Scene): Animations and value data.
  - `Map` (Scene): Tilemap for dirt, water, and grass. Y-Sort node containing Bushes, Chickens, and Hunters.

---

## User Review Required

> [!IMPORTANT]
> **Multiplayer vs Bots**
> The HTML prototype features 1 Player vs 2 AI Bots. The original specification mentioned a "multiplayer party game". For the Godot implementation, should all 3 chickens be controlled by human players (Local Multiplayer via gamepads/keyboard), or should it remain 1 Player vs 2 AI Bots? 

---

## Development Milestones (Godot)

### Milestone 1: Godot Project Setup & Core Movement
- Initialize Godot 4.x 2D project.
- Set up Project Settings (Pixel snap, integer scaling, window size).
- Create the `Chicken` scene (`CharacterBody2D`).
- Implement basic 8-way movement and the Dash mechanic (speed boost + cooldown).

### Milestone 2: Map, Hiding, & Worms
- Create the main game scene with a basic TileMap (grass, dirt paths, pond).
- Create the `Bush/Cornfield` scene (`Area2D`). Implement opacity changing and "isHidden" flag when a chicken enters.
- Create the `Worm` scene. Implement spawning logic (Normal vs Golden) and collection (increasing score).

### Milestone 3: Combat & Interactions
- Add Hitboxes and Hurtboxes to the `Chicken` scene.
- Implement Dash collisions: Stun state, point deduction, screen shake, and worm dropping/scattering.

### Milestone 4: AI Hunters
- Create the `Hunter` scene (`CharacterBody2D`).
- Implement Patrol state (moving to random points).
- Implement Vision Cone/Radius (`Area2D`).
- Implement Chase state (targeting the nearest visible chicken) and catch penalty (point deduction, stun, bounce back).

### Milestone 5: UI, Game Loop, & Polish
- Implement the 3-minute match timer.
- Build the HUD (Scoreboard, Timer).
- Implement the Game Over screen and win condition logic.
- Add sound effects, floating text for score changes, and particle effects.

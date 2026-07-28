# Repository Cleanup & YATI Migration Plan

This report outlines the complete audit of the repository to prepare for the YATI migration. 

No files have been modified or deleted yet. Awaiting your approval.

---

## Phase 1 — Audit (Custom TMX & Placeholder Compilers)

The project currently contains multiple experimental scripts used to generate the temporary Sandbox map and the failed TMX map.

| File | Purpose | Status |
|------|---------|--------|
| `scripts/tools/tmx_compiler.gd` | The failed custom TMX parser. | **DELETE** |
| `build_level.gd` | Procedurally generates the placeholder `Level.tscn`. | **DELETE** |
| `generate_tileset.gd` | Procedurally generates the placeholder `tileset.tres`. | **DELETE** |
| `gen_tiles.py` | Python script that generated the placeholder tile images. | **DELETE** |
| `scripts/environment/level_builder.gd` | Script attached to the generated placeholder `Level.tscn`. | **DELETE** |

---

## Phase 2 — Preserve Assets

The following assets have been verified and will **not** be modified or deleted.

- `assets/maps/ChickenGangMap.tmx`
- `assets/maps/*.tsx` (All 8 external tilesets)
- `assets/maps/*.png` (All pixel art textures)
- `assets/` (Any other sprites/art)
- `audio/` (All sound assets)
- `character reference/`

---

## Phase 3 — Remove Generated Artifacts

The following generated artifacts are obsolete or broken and can safely be removed to ensure a clean slate for YATI.

- `scenes/environment/ChickenGangMap.tscn` (Broken generated map from `tmx_compiler.gd`)
- `scenes/environment/Level.tscn` (Placeholder map from `build_level.gd`)
- `tileset.tres` (Placeholder tileset from `generate_tileset.gd`)

---

## Phase 4 — Dependency Audit

The following files contain hardcoded references to the custom/placeholder files that are slated for deletion:

- `main.tscn`: Currently instantiates `res://scenes/environment/Level.tscn`. 
  - *Action Required Later:* Update `main.tscn` to load the YATI-generated scene instead.

---

## Phase 5 — Migration Preparation

Here is the exact impact YATI will have on existing systems. 

As requested, I have verified your assumption: **Only LevelManager requires meaningful modification.**

| System | Impact | Reason |
|--------|--------|--------|
| **GameManager** | NO CHANGE | Continues to listen to `level_ready` and instantiates entities. |
| **LevelManager** | MAJOR CHANGE | YATI will generate a scene tree. `LevelManager` must be updated to traverse the YATI object layers (to find spawns, tractor paths, hiding spots) instead of relying on the old `SpawnPoint` nodes. |
| **SignalBus** | NO CHANGE | Global events remain identical. |
| **DynamicCamera** | NO CHANGE | `GameManager` will continue to pass player targets to the camera. |
| **PlayerController** | NO CHANGE | Gameplay logic is independent of the map. |
| **Hunter (AI)** | NO CHANGE | Finite state machine operates independently of map generation. |
| **UI** | NO CHANGE | HUD elements do not depend on the environment. |
| **Audio** | NO CHANGE | Sound triggers remain independent. |
| **Spawn Logic** | NO CHANGE | `GameManager` still handles spawning logic using positions provided by `LevelManager`. |
| **World Loading** | MINOR CHANGE | `main.tscn` will point to the YATI scene instead of `Level.tscn`. |

---

## Phase 6 — Repository Cleanup Plan

Here is the final checklist to execute once approved:

- [ ] Delete `scripts/tools/tmx_compiler.gd`
- [ ] Delete `build_level.gd`
- [ ] Delete `generate_tileset.gd`
- [ ] Delete `gen_tiles.py`
- [ ] Delete `scripts/environment/level_builder.gd`
- [ ] Delete `scenes/environment/ChickenGangMap.tscn`
- [ ] Delete `scenes/environment/Level.tscn`
- [ ] Delete `tileset.tres`
- [ ] Update `main.tscn` to temporarily remove the `Level.tscn` instance (so the project runs without crashing).
- [ ] Preserve all TMX, TSX, PNG, and audio assets.
- [ ] Preserve all gameplay, architecture, and manager scripts.
- [ ] Repository ready for YATI installation.

Please provide your explicit approval to execute this cleanup plan.

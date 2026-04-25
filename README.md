# Fatherload

A 2D underground mining game built with Godot 4. Pilot a drilling pod into the earth, excavate valuable ores, and survive as long as your fuel and health hold out.

Play it [here](https://thulasipavankumar.github.io/fatherload/).

## Gameplay

- Drill left, right, and downward through procedurally generated terrain to collect ores.
- The pod falls freely through tunnel spaces and lands on solid ground — use gravity to your advantage.
- Flying upward is only possible through existing tunnels or above the surface.
- Fuel drains constantly; running out of fuel or health ends the run.
- Falling from large heights deals fall damage on landing.

## Controls

| Key | Action |
|-----|--------|
| Arrow Left / Right | Move and drill horizontally |
| Arrow Down | Drill downward |
| Arrow Up | Fly upward (tunnels and open sky only) |

Horizontal and vertical movement are mutually exclusive — no diagonal movement.

## Fall Damage

Gravity accelerates the pod downward at **400 px/s²**, capped at a terminal velocity of **600 px/s**.

When the pod lands, the impact speed is compared against a safe threshold:

```
damage = (impact_speed - 300) × 0.2
```

| Fall duration | Impact speed | Damage |
|---|---|---|
| < ~0.75 s | < 300 px/s | 0 |
| ~1 s | 400 px/s | 20 |
| ~1.25 s | 500 px/s | 40 |
| terminal | 600 px/s | 60 |

Falls below **300 px/s** are safe. The terminal velocity cap means no single fall can deal more than **60 damage** (on a 100 HP pod). The three constants in `player.gd` that control this are:

| Constant | Default | Effect |
|---|---|---|
| `TERMINAL_VELOCITY` | 600 | Maximum fall speed (px/s) |
| `FALL_DAMAGE_MIN_SPEED` | 300 | Speed below which falls are safe |
| `FALL_DAMAGE_MULTIPLIER` | 0.2 | Damage per px/s above the threshold |

## Ores

Ores spawn at depth-dependent rates. Each ore has an optimal depth range where it appears most frequently, with a gaussian falloff outside that range. Rarer ores appear deeper.

## Project Structure

```
fatherload/
├── scripts/
│   ├── main.gd          # Game loop, restart, UI signal routing
│   ├── player.gd        # Movement, digging, fuel/health, animations
│   ├── ore_data.gd      # Ore resource definition (value, depth, drill strength)
│   ├── fuel_bar.gd      # Fuel progress bar UI
│   ├── health_bar.gd    # Health progress bar UI
│   ├── altitude_label.gd # Depth display
│   └── cash_label.gd    # Cash display
├── scenes/
│   ├── map.tscn         # Root scene
│   ├── underground.tscn # Procedural tilemap (ground + ore layers)
│   ├── underground.gd   # Terrain generation, digging, tile queries
│   └── player.tscn      # Pod character with animations
├── data/
│   ├── ground_tile.gd   # Tile data class (type + optional ore ref)
│   ├── ground_type.gd   # Enum: TUNNEL, DIRT, ORE
│   ├── ore_type.gd      # Enum of all ore types
│   └── ores/            # .tres resource files for each ore
└── assets/
    ├── images/          # Sprites and tilesets
    └── audio/           # Sound effects
```

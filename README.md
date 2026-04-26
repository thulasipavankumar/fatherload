# Fatherload

A 2D underground mining game built with Godot 4. Pilot a drilling pod into the earth, excavate valuable ores, manage your fuel and health, and push deeper than your last run.

Play it [here](https://thulasipavankumar.github.io/fatherload/).

---

## Gameplay

Drill left, right, and downward through procedurally generated terrain. Ore gets richer the deeper you go — but so does the danger. The pod falls freely through tunnel spaces and lands on solid ground. Fly upward only through existing tunnels or open sky. Fuel drains constantly, and a bad landing can take a serious chunk of your health.

When you die, a **Run Summary** breaks down exactly how far you made it and what you found. Use that to do better next time.

---

## Controls

| Key | Action |
|-----|--------|
| A / D  or  ← / → | Move and drill horizontally |
| S  or  ↓ | Drill downward |
| W  or  ↑ | Fly upward (tunnels and open sky only) |

Horizontal and vertical inputs are mutually exclusive — no diagonal movement.

**Movement is fast in open space and automatically slows to drilling speed when solid rock is nearby.** You don't have to do anything — the pod detects what's ahead and shifts gears.

---

## Fuel

Fuel drains every few seconds while the game is running. The fuel bar sits in the top-right corner.

- When fuel drops to **20 or below**, the bar turns red and shakes as a warning.
- Reach the **Fuel Station** (just right of your start position) to refuel — it costs **$10 per unit**. You're charged only for what you need and what you can afford.
- Running out of fuel ends the run.

**Fuel Tank upgrades** (available at the Upgrade Shop) permanently increase your tank capacity for the run, giving you more time underground before needing to resurface.

---

## Health

The pod starts with **100 HP**. Health is lost from:

- **Fall damage** — gravity accelerates you at 400 px/s², capped at 600 px/s terminal velocity. Landings above 300 px/s deal damage based on excess speed.
- Future: enemy encounters, hazardous ores.

```
damage = (impact_speed − 300) × 0.2
```

| Impact speed | Damage |
|---|---|
| < 300 px/s | 0 (safe) |
| 400 px/s | 20 |
| 500 px/s | 40 |
| 600 px/s (terminal) | 60 |

The health bar is in the top-left. The sprite flashes red on a damaging landing. Health hits zero → run over.

---

## Ores

21 ore types span from common surface rock to deep legendary finds. Each ore has an **optimal depth range** where it spawns most frequently, with a smooth gaussian falloff above and below that range. Rarer ores sit deeper — you won't find diamonds near the surface.

| Tier | Examples | Rough Depth |
|---|---|---|
| Common | Rock, Coal, Iron, Scrap | 0 – 30 |
| Uncommon | Bronze, Silver, Lapis Lazuli | 10 – 60 |
| Rare | Gold, Platinum, Emerald, Sapphire, Ruby | 40 – 100 |
| Deep | Diamond, Mithril, Uranium | 70 – 130 |
| Legendary | Dinosaur Bones, Asteroid, Relic, Treasure | 90+ |

Every ore tile visually distinct — the tileset shows exactly what you're drilling into before you commit.

---

## Upgrade Shop

Walk into the **Upgrade Shop** (to the right along the surface) to spend your cash on permanent upgrades for the current run.

| Upgrade | Effect | Cost (per tier) |
|---|---|---|
| Fuel Tank | +30 max fuel | $150 / $300 / $600 |
| Hull Armor | +25 max health | $100 / $250 / $500 |
| Speed Engine | +20 move speed | $250 / $500 |
| Drill Bit | +15 drill speed | $200 / $400 |

Upgrades reset each run — every run starts fresh, so every decision counts. The shop flashes red if you can't afford the upgrade you're clicking.

---

## Run Summary

When a run ends (fuel or health hits zero), a summary screen appears before you restart:

```
RUN OVER
────────────────────────
Depth Reached:   342m
Cash Earned:     $1,240
Ores Mined:      47
Best Ore:        Diamond ($200)
────────────────────────
         [ Play Again ]
```

Use it as your personal scoreboard — push for deeper depths, more ores, or rarer finds.

---

## World & Background

- The map is **5,000 px wide** with camera and player hard-clamped to the map edges — no falling off into the void.
- The background fills the full width: tiled ground strips and sky strips are generated at startup to cover the entire map.
- A **plane** occasionally flies across the sky from right to left at a random speed and altitude, just for atmosphere.

---

## Fall Damage Reference

| Constant | Value | Effect |
|---|---|---|
| `TERMINAL_VELOCITY` | 600 px/s | Maximum fall speed |
| `FALL_DAMAGE_MIN_SPEED` | 300 px/s | Speed below which falls are safe |
| `FALL_DAMAGE_MULTIPLIER` | 0.2 | Damage per px/s above threshold |

---

## Project Structure

```
fatherload/
├── scripts/
│   ├── main.gd              # Game loop, restart, UI signal routing, run summary
│   ├── player.gd            # Movement, digging, fuel/health, animations, run stats
│   ├── underground.gd       # Terrain generation, digging, tile queries, ore rendering
│   ├── ore_data.gd          # Ore resource definition (value, depth range, spawn weight)
│   ├── shop.gd              # Upgrade shop: programmatic UI, upgrade tiers, cash checks
│   ├── fuel_bar.gd          # Fuel bar with red shake warning at low fuel
│   ├── health_bar.gd        # Health bar UI
│   ├── background.gd        # Background tiling + plane flyby animation
│   ├── altitude_label.gd    # Depth display
│   ├── cash_label.gd        # Cash display
│   └── toggle_button.gd     # Sound mute toggle
├── scenes/
│   ├── map.tscn             # Root scene — all game nodes wired here
│   ├── underground.tscn     # Procedural tilemap (ground + ore layers)
│   ├── player.tscn          # Pod character with animations and sounds
│   ├── fuel_station.tscn    # Surface refuel station
│   ├── shop.tscn            # Upgrade shop trigger area
│   └── background.tscn      # Tiled sky, ground backdrops, plane sprite
├── data/
│   ├── ground_tile.gd       # Tile data class (type + optional ore ref)
│   ├── ground_type.gd       # Enum: TUNNEL, DIRT, ORE
│   └── ores/                # 21 .tres resource files, one per ore type
└── assets/
    ├── images/              # Sprites, tilesets, UI textures
    └── audio/               # Background music, movement and mining SFX
```

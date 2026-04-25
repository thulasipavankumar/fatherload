extends Node2D

@export var ores: Array[OreData]
@onready var ground_layer: TileMapLayer = $Ground
@onready var ore_layer: TileMapLayer = $Ores

# Probability that any given tile spawns as an empty tunnel instead of dirt.
const tunnel_probability = 0.15;
# Probability that a non-tunnel tile contains an ore (subject to depth weighting).
const ore_probability = 0.5;
# Ore spawn chances below this threshold are ignored to avoid near-zero rolls.
const ore_spawn_chance_cutoff = 0.0001;

const tunnel_tile_source_id = 0
const tunnel_tile_coords = Vector2i(0, 6)

# Maps tile position → OreData so dig() can return the correct value.
var ore_map: Dictionary = {}

func _ready():
	randomize()
	_assign_missing_values()
	generate_chunk(100, 100, 0, Vector2i(0, 0))

# Regenerates the entire terrain with a new random seed (called on game restart).
func reset():
	randomize()
	ore_map.clear()
	generate_chunk(100, 100, 0, Vector2i(0, 0))

# Any ore with value == 0 in its .tres file gets a random value scaled by rarity.
# Rarer ores (lower spawn_chance) receive proportionally higher values.
func _assign_missing_values():
	for ore in ores:
		if ore.value == 0.0:
			var rarity_scale: float = 100.0 / max(ore.spawn_chance, 1.0)
			ore.value = round(clampf(randf_range(5.0, 20.0) * rarity_scale, 1.0, 500.0))

# Returns true if the tile at pos can be drilled (i.e. it is dirt or ore, not a tunnel).
func is_diggable(pos: Vector2i) -> bool:
	var source_id := ground_layer.get_cell_source_id(pos)
	if source_id == -1:
		return false
	var atlas_coords := ground_layer.get_cell_atlas_coords(pos)
	return atlas_coords != tunnel_tile_coords

# Returns true if the tile at pos is an explicit tunnel tile.
# Used to distinguish tunnels from out-of-bounds empty space.
func is_tunnel(pos: Vector2i) -> bool:
	var source_id := ground_layer.get_cell_source_id(pos)
	if source_id == -1:
		return false
	return ground_layer.get_cell_atlas_coords(pos) == tunnel_tile_coords

# Converts a solid tile into a tunnel and returns the ore value (0 if it was plain dirt).
func dig(pos: Vector2i) -> float:
	var value := 0.0
	if ore_map.has(pos):
		value = ore_map[pos].value
		ore_map.erase(pos)
	_clear_ore(pos)
	_set_tunnel(pos)
	return value

# Generates a width×height block of tiles starting at origin, with depth used for
# ore distribution weighting. Returns the raw chunk data array.
func generate_chunk(width: int, height: int, depth: int, origin: Vector2i):
	var chunk = _create_chunk(width, height, depth)
	_render_chunk(chunk, origin)
	return chunk

func _clear_ore(pos: Vector2i):
	ore_layer.erase_cell(pos)

func _set_tunnel(pos: Vector2i):
	ground_layer.set_cell(
		pos,
		tunnel_tile_source_id,
		tunnel_tile_coords
	)

# Writes the chunk data array to both tile map layers, clearing any previous tiles first.
func _render_chunk(chunk: Array, chunk_origin: Vector2i):
	for y in range(chunk.size()):
		for x in range(chunk[y].size()):
			var cell = chunk[y][x]
			var tile_pos := Vector2i(
				chunk_origin.x + x,
				chunk_origin.y + y
			)

			# Clear old tiles and any stale ore entry.
			ground_layer.erase_cell(tile_pos)
			ore_layer.erase_cell(tile_pos)
			ore_map.erase(tile_pos)

			match cell.type:
				GroundTypes.GroundType.TUNNEL:
					ground_layer.set_cell(tile_pos, 0, Vector2i(0, 6))

				GroundTypes.GroundType.DIRT:
					ground_layer.set_cell(tile_pos, 0, Vector2i(0, 0))

				GroundTypes.GroundType.ORE:
					# Dirt background first, then ore overlay.
					ground_layer.set_cell(tile_pos, 0, Vector2i(0, 0))
					ore_layer.set_cell(tile_pos, 1, Vector2i(0, 3))
					ore_map[tile_pos] = cell.ore

# Builds the raw chunk array by calling _create_ground_cell for every position.
func _create_chunk(width: int, height: int, depth: int):
	var chunk: Array = [];
	for y in range(height):
		var row: Array = []
		var cell_depth := depth + y
		for x in range(width):
			row.append(_create_ground_cell(cell_depth))
		chunk.append(row)
	return chunk

# Decides the type of a single tile at the given depth:
# tunnel (15% chance) → dirt → ore (weighted by depth proximity to each ore's optimal range).
func _create_ground_cell(depth: int):
	var cell := GroundTile.new(GroundTypes.GroundType.DIRT)
	if randf() < tunnel_probability:
		cell.type = GroundTypes.GroundType.TUNNEL
		return cell;

	if (randf() < ore_probability):
		var total := 0.0
		var effective_chances := {}

		for ore in ores:
			var factor := _get_depth_factor(depth, ore)
			var spawn_chance := ore.spawn_chance * factor
			if spawn_chance <= ore_spawn_chance_cutoff:
				continue

			effective_chances[ore] = spawn_chance
			total += spawn_chance

		if total <= 0.0:
			return cell

		# Weighted random selection across all eligible ores.
		var roll := randf() * total
		var running := 0.0

		for ore in effective_chances.keys():
			running += effective_chances[ore]
			if roll <= running:
				cell.type = GroundTypes.GroundType.ORE
				cell.ore = ore
				break

	return cell

# Returns a 0–1 multiplier for how likely an ore is to spawn at this depth.
# Full probability (1.0) within the ore's optimal range; gaussian falloff outside it.
func _get_depth_factor(depth: int, ore: OreData) -> float:
	var min_d := ore.min_optimal_depth
	var max_d := ore.max_optimal_depth

	if depth >= min_d and depth <= max_d:
		return 1.0

	var fade_distance := 20.0

	if depth < min_d:
		var t := (min_d - depth) / fade_distance
		return exp(-t * t)

	if depth > max_d:
		var t := (depth - max_d) / fade_distance
		return exp(-t * t)

	return 0.0

# Debug helper — prints the chunk as ASCII art (space=tunnel, dot=dirt, letter=ore initial).
func _print_chunk_ascii(chunk: Array):
	for row in chunk:
		var line := ""
		for cell in row:
			match cell.type:
				GroundTypes.GroundType.TUNNEL:
					line += " "
				GroundTypes.GroundType.DIRT:
					line += "."
				GroundTypes.GroundType.ORE:
					line += cell.ore.name[0]
		print(line)

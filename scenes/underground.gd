extends Node2D

@export var ores: Array[OreData]
@onready var ground_layer: TileMapLayer = $Ground
@onready var ore_layer: TileMapLayer = $Ores

const tunnel_probability = 0.15;
const ore_probability = 0.5;
const ore_spawn_chance_cutoff = 0.0001;

const tunnel_tile_source_id = 0
const tunnel_tile_coords = Vector2i(0, 6)

func _ready():
	print("Test")
	randomize()
	var chunk = generate_chunk(100, 100, 0, Vector2i(0, 0))
	await get_tree().create_timer(5.0).timeout
	dig(Vector2i(0,0))
	
func dig(pos: Vector2i):
	_clear_ore(pos)
	_set_tunnel(pos)
	
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

func _render_chunk(chunk: Array, chunk_origin: Vector2i):
	for y in range(chunk.size()):
		for x in range(chunk[y].size()):
			var cell = chunk[y][x]
			var tile_pos := Vector2i(
				chunk_origin.x + x,
				chunk_origin.y + y
			)

			# Clear old tiles
			ground_layer.erase_cell(tile_pos)
			ore_layer.erase_cell(tile_pos)

			match cell.type:
				GroundTypes.GroundType.TUNNEL:
					ground_layer.set_cell(
						tile_pos,
						0,
						Vector2i(0, 6)
					)

				GroundTypes.GroundType.DIRT:
					ground_layer.set_cell(
						tile_pos,
						0,
						Vector2i(0, 0)
					)

				GroundTypes.GroundType.ORE:
					# Dirt background first
					ground_layer.set_cell(
						tile_pos,
						0,
						Vector2i(0, 0)
					)

					# Ore overlay
					ore_layer.set_cell(
						tile_pos,
						1,
						Vector2i(0, 3)
					)

func _create_chunk(width: int, height: int, depth: int):
	var chunk: Array = [];
	for y in range(height):
		var row: Array = []
		var cell_depth := depth + y
		for x in range(width):
			row.append(_create_ground_cell(cell_depth))
		chunk.append(row)
	return chunk
	
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

		var roll := randf() * total
		var running := 0.0

		for ore in effective_chances.keys():
			running += effective_chances[ore]
			if roll <= running:
				cell.type = GroundTypes.GroundType.ORE
				cell.ore = ore
				break
		
	return cell
	
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

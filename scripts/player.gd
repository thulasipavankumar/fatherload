extends CharacterBody2D

@export var maxFuel: int = 100
var currentFuel: int = maxFuel
signal fuel_changed(new_fuel)
@onready var sfx_move: AudioStreamPlayer = $sfx_move
@onready var sfx_fly: AudioStreamPlayer = $sfx_fly
@onready var sfx_mine: AudioStreamPlayer2D = $sfx_mine
@onready var sfx_fuel_low: AudioStreamPlayer = $sfx_fuel_low

@export var max_health := 100
var health := max_health
signal health_changed(new_health)

var cash: int = 0
signal cash_changed(new_cash)

signal died
var SPEED: float = 200.0
var MINING_SPEED: float = 100.0
const GRAVITY = 400.0
const TERMINAL_VELOCITY = 600.0
# Minimum fall speed (px/s) before damage kicks in.
const FALL_DAMAGE_MIN_SPEED = 300.0
# Damage per px/s of speed above the threshold.
const FALL_DAMAGE_MULTIPLIER = 0.2
var last_direction: Vector2 = Vector2.RIGHT
var _start_position: Vector2
var _active_direction: Vector2 = Vector2.ZERO
var _base_max_fuel: int
var _base_max_health: int
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

enum AnimState { IDLE, TURNING, MOVING }
var anim_state: AnimState = AnimState.IDLE

# Set by main.gd so the player can query and modify the tile map.
var underground: Node2D = null

# Per-run stats tracked for the death summary.
var max_depth_reached: float = 0.0
var ores_mined: int = 0
var best_ore_name: String = "None"
var best_ore_value: float = 0.0
var total_cash_earned: int = 0
var death_cause: String = ""


# Upgrades the fuel tank capacity (called from fuel station or shop).
func increase_fuel_capacity(capacity: int):
	maxFuel = capacity

func upgrade_fuel_tank(amount: int) -> void:
	maxFuel += amount
	currentFuel = min(currentFuel + amount, maxFuel)
	emit_signal("fuel_changed", currentFuel)

func upgrade_hull(amount: int) -> void:
	max_health += amount
	health = min(health + amount, max_health)
	emit_signal("health_changed", health)

func _ready() -> void:
	_start_position = position
	_base_max_fuel = maxFuel
	_base_max_health = max_health
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	

# Resets all stats and position to their starting values (called on restart).
func reset() -> void:
	maxFuel = _base_max_fuel
	max_health = _base_max_health
	SPEED = 200.0
	MINING_SPEED = 100.0
	health = max_health
	currentFuel = maxFuel
	cash = 0
	max_depth_reached = 0.0
	ores_mined = 0
	best_ore_name = "None"
	best_ore_value = 0.0
	total_cash_earned = 0
	death_cause = ""
	position = _start_position
	velocity = Vector2.ZERO
	anim_state = AnimState.IDLE
	_active_direction = Vector2.ZERO
	emit_signal("health_changed", health)
	emit_signal("fuel_changed", currentFuel)
	emit_signal("cash_changed", cash)
	sfx_fuel_low.stop()

func _physics_process(delta: float) -> void:
	process_movement(delta)
	process_animation()
	try_dig()
	move_and_slide()
	_clamp_to_map()
	_update_depth_stat()

func _update_depth_stat() -> void:
	var depth := (position.y - _start_position.y) / 25.0
	if depth > max_depth_reached:
		max_depth_reached = depth

func _clamp_to_map() -> void:
	if underground == null:
		return
	var tile_size: Vector2i = underground.ground_layer.tile_set.tile_size
	var used: Rect2i = underground.ground_layer.get_used_rect()
	var map_left := underground.position.x + used.position.x * tile_size.x
	var map_right := underground.position.x + used.end.x * tile_size.x
	position.x = clampf(position.x, map_left, map_right)

# Adds fuel up to the tank capacity.
func refill_fuel(value: int):
	if currentFuel >= maxFuel: return
	currentFuel = min(currentFuel + value, maxFuel)
	emit_signal("fuel_changed", currentFuel)
	if currentFuel > 20:
		sfx_fuel_low.stop()

# Restores health up to the maximum.
func refill_health(value: int):
	if health >= max_health: return
	health = min(health + value, max_health)
	emit_signal("health_changed", health)

# Digs the tile in the active input direction (left, right, or down only).
# Up is excluded — the player can fly through tunnels but cannot drill ceilings.
# Diagonal input is already resolved by process_movement, so only one axis fires here.
func try_dig() -> void:
	if underground == null:
		return
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var dig_dir := Vector2.ZERO
	if abs(input_dir.x) > abs(input_dir.y):
		dig_dir = Vector2(sign(input_dir.x), 0)
	elif input_dir.y > 0:
		dig_dir = Vector2.DOWN
	if dig_dir == Vector2.ZERO:
		sfx_mine.stop()
		return
	var dig_point := position + dig_dir * 30
	var local_pos := dig_point - underground.position
	var tile_pos: Vector2i = underground.ground_layer.local_to_map(local_pos)
	if underground.is_diggable(tile_pos):
		var ore_data = underground.ore_map.get(tile_pos, null)
		var ore_value: float = underground.dig(tile_pos)
		consume_fuel(1)
		if ore_value > 0:
			add_cash(int(ore_value))
			ores_mined += 1
			total_cash_earned += int(ore_value)
			if ore_data and ore_value > best_ore_value:
				best_ore_value = ore_value
				best_ore_name = ore_data.name
		if not sfx_mine.playing:
			sfx_mine.play()

# Returns true when the tile just below the player's feet is solid (dirt or ore).
func _is_on_ground() -> bool:
	if underground == null:
		return false
	var tile_size: Vector2i = underground.ground_layer.tile_set.tile_size
	var below := position + Vector2(0, float(tile_size.y) * 0.5 + 2.0)
	var local_pos := below - underground.position
	var tile_pos: Vector2i = underground.ground_layer.local_to_map(local_pos)
	return underground.is_diggable(tile_pos)

# Returns true when the tile just above the player's head is passable
# (tunnel tile or outside the map bounds = open sky).
func _can_fly_up() -> bool:
	if underground == null:
		return false
	var tile_size: Vector2i = underground.ground_layer.tile_set.tile_size
	var above := position + Vector2(0, -float(tile_size.y) * 0.5 - 2.0)
	var local_pos := above - underground.position
	var tile_pos: Vector2i = underground.ground_layer.local_to_map(local_pos)
	return not underground.is_diggable(tile_pos)

# Aligns the player's y position to sit flush on top of the solid tile below.
# Prevents the player from sinking into or hovering above the ground tile.
func _snap_to_floor() -> void:
	var tile_size: Vector2i = underground.ground_layer.tile_set.tile_size
	var half_tile_y := float(tile_size.y) * 0.5
	var below := position + Vector2(0, half_tile_y + 2.0)
	var local_pos := below - underground.position
	var tile_pos: Vector2i = underground.ground_layer.local_to_map(local_pos)
	var tile_center: Vector2 = underground.ground_layer.map_to_local(tile_pos)
	position.y = underground.position.y + tile_center.y - half_tile_y - half_tile_y

# Handles all velocity updates each physics frame.
# Rules:
#   - Horizontal and vertical input are mutually exclusive (no diagonal movement).
#   - Pressing up flies the player upward only when the tile above is passable.
#   - Gravity accumulates when airborne; landing snaps the player to the tile surface.
#   - Pressing down sets a fixed downward speed for active floor-digging.
func _is_mining(direction: Vector2) -> bool:
	if underground == null:
		return false
	var dig_dir := Vector2.ZERO
	if abs(direction.x) > abs(direction.y):
		dig_dir = Vector2(sign(direction.x), 0)
	elif direction.y > 0:
		dig_dir = Vector2.DOWN
	if dig_dir == Vector2.ZERO:
		return false
	# Check across two tile-widths ahead so speed stays low between tiles.
	for dist: float in [20.0, 40.0, 60.0, 80.0]:
		var dig_point := position + dig_dir * dist
		var local_pos := dig_point - underground.position
		var tile_pos: Vector2i = underground.ground_layer.local_to_map(local_pos)
		if underground.is_diggable(tile_pos):
			return true
	return false

func process_movement(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	# Lock to one axis — horizontal takes priority over vertical input.
	if direction.x != 0:
		direction.y = 0.0
	var current_speed := MINING_SPEED if _is_mining(direction) else SPEED
	velocity.x = direction.x * current_speed
	var impact_speed := velocity.y
	if direction.y < 0 and _can_fly_up():
		velocity.y = -current_speed
	elif _is_on_ground() and velocity.y >= 0:
		if impact_speed > FALL_DAMAGE_MIN_SPEED:
			take_damage(int((impact_speed - FALL_DAMAGE_MIN_SPEED) * FALL_DAMAGE_MULTIPLIER))
			_flash_fall_damage()
		velocity.y = 0.0
		_snap_to_floor()
	else:
		velocity.y = minf(velocity.y + GRAVITY * delta, TERMINAL_VELOCITY)
	if direction.y > 0:
		velocity.y = current_speed
	# Track facing direction for animation — also updated when falling.
	if direction.x != 0:
		last_direction = Vector2(sign(direction.x), 0)
	elif direction.y < 0:
		last_direction = Vector2.UP
	elif direction.y > 0:
		last_direction = Vector2.DOWN
	elif velocity.y > 10.0:
		last_direction = Vector2.DOWN

# Briefly tints the sprite red then fades back to normal to signal fall damage.
func _flash_fall_damage() -> void:
	animated_sprite_2d.modulate = Color(1.0, 0.2, 0.2, 1.0)
	var tween := create_tween()
	tween.tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.4)

# Drives the sprite state machine: IDLE → TURNING → MOVING.
# A turning animation plays once when direction changes before looping the move animation.
func process_animation() -> void:
	if velocity == Vector2.ZERO:
		anim_state = AnimState.IDLE
		sfx_move.stop()
		sfx_fly.stop()
		play_animation("idle", last_direction)
		return

	if last_direction != _active_direction or anim_state == AnimState.IDLE:
		anim_state = AnimState.TURNING
		_active_direction = last_direction
		play_animation("turn", _active_direction)

# Advances from TURNING to MOVING once the turn animation finishes.
func _on_animation_finished() -> void:
	if anim_state == AnimState.TURNING:
		anim_state = AnimState.MOVING
		play_animation("move", _active_direction)

# Plays the correct directional animation and toggles the matching sound effect.
# Horizontal movement uses sfx_move; vertical (up) uses sfx_fly.
func play_animation(prefix: String, dir: Vector2) -> void:
	if prefix == "idle":
		animated_sprite_2d.rotation = 0.0
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("idle")
		return
	if dir.x != 0:
		animated_sprite_2d.rotation = 0.0
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
		if prefix == "move":
			sfx_fly.stop()
			if !sfx_move.playing:
				sfx_move.play()
	elif dir.y < 0:
		animated_sprite_2d.rotation = 0.0
		animated_sprite_2d.play(prefix + "_up")
		if prefix == "move":
			sfx_move.stop()
			if !sfx_fly.playing:
				sfx_fly.play()
	elif dir.y > 0:
		# Rotate the sprite 90° clockwise so it faces downward.
		animated_sprite_2d.rotation = PI / 2.0
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play(prefix + "_right")
		if prefix == "move":
			sfx_fly.stop()
			if !sfx_move.playing:
				sfx_move.play()

func add_cash(amount: int):
	cash += amount
	emit_signal("cash_changed", cash)

func spend_cash(amount: int):
	cash = max(cash - amount, 0)
	emit_signal("cash_changed", cash)

# Drains fuel, plays low-fuel warning when at or below 20, and triggers death at zero.
func consume_fuel(amount: int):
	currentFuel = max(currentFuel - amount, 0)
	emit_signal("fuel_changed", currentFuel)
	if currentFuel <= 20 and not sfx_fuel_low.playing:
		sfx_fuel_low.play()
	if currentFuel <= 0:
		death_cause = "Fuel exhausted"
		died.emit()

# Applies damage and triggers death when health hits zero.
func take_damage(amount: int):
	health = max(health - amount, 0)
	emit_signal("health_changed", health)
	if health <= 0:
		death_cause = "Hull destroyed"
		died.emit()

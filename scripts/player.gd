extends CharacterBody2D

@export var maxFuel = 100
var currentFuel: int = maxFuel
signal fuel_changed(new_fuel)
@onready var sfx_move: AudioStreamPlayer = $sfx_move
@onready var sfx_fly: AudioStreamPlayer = $sfx_fly

@export var max_health := 100
var health := max_health
signal health_changed(new_health)

var cash: int = 0
signal cash_changed(new_cash)

signal died
const SPEED = 100.0
var last_direction: Vector2 = Vector2.RIGHT
var _start_position: Vector2
var _active_direction: Vector2 = Vector2.ZERO
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

enum AnimState { IDLE, TURNING, MOVING }
var anim_state: AnimState = AnimState.IDLE


func increase_fuel_capacity(capacity: int):
	maxFuel = capacity

func _ready() -> void:
	_start_position = position
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func reset() -> void:
	health = max_health
	currentFuel = maxFuel
	position = _start_position
	velocity = Vector2.ZERO
	anim_state = AnimState.IDLE
	_active_direction = Vector2.ZERO
	emit_signal("health_changed", health)
	emit_signal("fuel_changed", currentFuel)

func _physics_process(_delta: float) -> void:
	process_movement()
	process_animation()
	move_and_slide()

func refill_fuel(value: int):
	if currentFuel >= maxFuel: return
	currentFuel = min(currentFuel + value, maxFuel)
	emit_signal("fuel_changed", currentFuel)

func refill_health(value: int):
	if health >= max_health: return
	health = min(health + value, max_health)
	emit_signal("health_changed", health)

func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
	else:
		velocity = Vector2.ZERO

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

func _on_animation_finished() -> void:
	if anim_state == AnimState.TURNING:
		anim_state = AnimState.MOVING
		play_animation("move", _active_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x > 0
		animated_sprite_2d.play(prefix + "_left")
		if prefix == "move":
			sfx_fly.stop()
			if !sfx_move.playing:
				sfx_move.play()
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
		if prefix == "move":
			sfx_move.stop()
			if !sfx_fly.playing:
				sfx_fly.play()
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_bottom")
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

func consume_fuel(amount: int):
	currentFuel = max(currentFuel - amount, 0)
	emit_signal("fuel_changed", currentFuel)
	if currentFuel <= 0:
		died.emit()

func take_damage(amount: int):
	health = max(health - amount, 0)
	emit_signal("health_changed", health)
	if health <= 0:
		died.emit()

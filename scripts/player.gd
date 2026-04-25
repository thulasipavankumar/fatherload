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
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func increase_fuel_capacity(capacity:int):
	maxFuel = capacity

func _ready() -> void:
	_start_position = position

func reset() -> void:
	health = max_health
	currentFuel = maxFuel
	position = _start_position
	velocity = Vector2.ZERO
	emit_signal("health_changed", health)
	emit_signal("fuel_changed", currentFuel)

func _physics_process(delta: float) -> void:
	process_movement()
	process_animation()
	move_and_slide()

func refill_fuel(value:int):
	if currentFuel >= maxFuel: return
	currentFuel = min(currentFuel + value, maxFuel)
	emit_signal("fuel_changed", currentFuel)

func refill_health(value:int):
	if health >= max_health: return
	health = min(health + value, max_health)
	emit_signal("health_changed", health)
	
func process_animation():
	if velocity!= Vector2.ZERO:
		play_animation("move",last_direction)
	else: 
		sfx_move.stop()
		sfx_fly.stop()
		play_animation("idle",last_direction)
	
	
	
func process_movement() -> void:
		# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left","right","up","down")
	if direction!=Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
	else:
		velocity = Vector2.ZERO
		
func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x > 0
		animated_sprite_2d.play(prefix + "_left")
		sfx_fly.stop()
		if !sfx_move.playing:
			sfx_move.play()
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
		sfx_move.stop()
		if !sfx_fly.playing:
			sfx_fly.play()
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_bottom")
		sfx_fly.stop()
		if !sfx_move.playing:
			sfx_move.play()
		
	
func add_cash(amount: int):
	cash += amount
	emit_signal("cash_changed", cash)

func spend_cash(amount: int):
	cash = max(cash - amount, 0)
	emit_signal("cash_changed", cash)

func consume_fuel(amount:int):
	currentFuel = max(currentFuel - amount, 0)
	emit_signal("fuel_changed", currentFuel)
	if currentFuel <= 0:
		died.emit()
	
	
func take_damage(amount: int):
	health = max(health - amount, 0)
	emit_signal("health_changed", health)
	if health <= 0:
		died.emit()
	
		

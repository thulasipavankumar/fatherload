extends CharacterBody2D

@export var maxFuel = 100
var currentFuel: int = maxFuel
signal fuel_changed(new_fuel)
@onready var sfx_move: AudioStreamPlayer = $sfx_move


@export var max_health := 100
var health := max_health
signal health_changed(new_health)

var cash: int = 0
signal cash_changed(new_cash)

signal died
const SPEED = 100.0
var last_direction: Vector2 = Vector2.RIGHT
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func increase_fuel_capacity(capacity:int):
	maxFuel = capacity


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
		play_animation("idle",last_direction)
	
	
	
func process_movement() -> void:
		# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left","right","up","down")
	if direction!=Vector2.ZERO:
		if !sfx_move.playing:
			sfx_move.play()
		velocity = direction * SPEED
		last_direction = direction
	else:
		sfx_move.stop()
		velocity = Vector2.ZERO
		
func play_animation(prefix:String,dir:Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x > 0
		animated_sprite_2d.play(prefix+"_left")
	elif dir.y<0:
		animated_sprite_2d.play(prefix+"_up")
	elif dir.y>0:
		animated_sprite_2d.play(prefix+"_bottom")
		
	
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
	
		

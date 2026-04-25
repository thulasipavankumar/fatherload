extends Node2D

func _ready() -> void:
	$player.died.connect(_on_player_died)
	$player.set_physics_process(false)
	$UILayer/RestartButton.hide()

func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	$UILayer/StartButton.hide()
	$player.set_physics_process(true)
	$FuelDrainTimer.start()

func _on_restart_button_pressed() -> void:
	$player.reset()
	$UILayer/RestartButton.hide()
	$player.set_physics_process(true)
	$FuelDrainTimer.start()

func _on_player_died() -> void:
	$player.set_physics_process(false)
	$FuelDrainTimer.stop()
	$UILayer/RestartButton.show()

func _on_fuel_drain_timer_timeout() -> void:
	consume_fuel(10)

func consume_fuel(value: int):
	$player.consume_fuel(value)

func take_damage(value: int):
	$player.take_damage(value)

func refill_fuel(value: int):
	$player.refill_fuel(value)

func refill_health(value: int):
	$player.refill_health(value)

func add_cash(value: int):
	$player.add_cash(value)

func spend_cash(value: int):
	$player.spend_cash(value)

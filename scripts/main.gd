extends Node2D

var _bgm: AudioStreamPlayer

func _ready() -> void:
	$player.died.connect(_on_player_died)
	$player.underground = $Underground
	$player.set_physics_process(false)
	$UILayer/RestartButton.hide()
	

	var stream: AudioStreamMP3 = load("res://assets/audio/background.mp3")
	stream.loop = true
	_bgm = AudioStreamPlayer.new()
	_bgm.stream = stream
	_bgm.volume_db = -5.0
	add_child(_bgm)

func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	$UILayer/StartButton.hide()
	$player.set_physics_process(true)
	$FuelDrainTimer.start()
	_bgm.play()

func _on_restart_button_pressed() -> void:
	$Underground.reset()
	$player.reset()
	$UILayer/RestartButton.hide()
	$player.set_physics_process(true)
	$FuelDrainTimer.start()
	_bgm.play()

func _on_player_died() -> void:
	$player.set_physics_process(false)
	$FuelDrainTimer.stop()
	$UILayer/RestartButton.show()
	_bgm.stop()

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

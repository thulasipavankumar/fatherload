extends Node2D

var _bgm: AudioStreamPlayer

func _ready() -> void:
	$player.died.connect(_on_player_died)
	$player.underground = $Underground
	$player.set_physics_process(false)
	$UILayer/StartButton.hide()
	$UILayer/RestartButton.hide()
	$UILayer/RunSummaryPanel.hide()
	$InstructionsLayer.start_pressed.connect(_on_start_button_pressed)
	_apply_camera_limits()

	var stream: AudioStreamMP3 = load("res://assets/audio/background.mp3")
	stream.loop = true
	_bgm = AudioStreamPlayer.new()
	_bgm.stream = stream
	_bgm.volume_db = -5.0
	add_child(_bgm)

func _apply_camera_limits() -> void:
	var ground_layer = $Underground.ground_layer
	var tile_size: Vector2i = ground_layer.tile_set.tile_size
	var used: Rect2i = ground_layer.get_used_rect()
	var map_left := int($Underground.position.x + used.position.x * tile_size.x)
	var map_right := int($Underground.position.x + used.end.x * tile_size.x)
	var camera: Camera2D = $player/Camera2D
	camera.limit_left = map_left
	camera.limit_right = map_right

func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	$UILayer/StartButton.hide()
	$InstructionsLayer.hide()
	$player.set_physics_process(true)
	$FuelDrainTimer.start()
	_bgm.play()

func _on_restart_button_pressed() -> void:
	$Underground.reset()
	$player.reset()
	$Shop.reset()
	$UILayer/RunSummaryPanel.hide()
	$player.set_physics_process(true)
	$FuelDrainTimer.start()
	_bgm.play()

func _on_player_died() -> void:
	$player.set_physics_process(false)
	$FuelDrainTimer.stop()
	_bgm.stop()
	# Ensure the depth at the moment of death is captured before reading stats,
	# because _update_depth_stat() runs at the end of _physics_process and may
	# not have executed yet in the same frame that emitted 'died'.
	var death_depth: float = $player._start_position.y / 25.0 - $player.position.y / 25.0
	if death_depth > $player.max_depth_reached:
		$player.max_depth_reached = death_depth
	_show_run_summary()

func _show_run_summary() -> void:
	var p = $player
	var panel = $UILayer/RunSummaryPanel
	panel.get_node("DepthLabel").text = "Depth Reached:  %dm" % int(p.max_depth_reached)
	panel.get_node("CashLabel").text  = "Cash Earned:    $%d" % p.total_cash_earned
	panel.get_node("OresLabel").text  = "Ores Mined:     %d" % p.ores_mined
	var best_str: String
	if p.ores_mined > 0:
		best_str = "%s  ($%d)" % [p.best_ore_name, int(p.best_ore_value)]
	else:
		best_str = "None"
	panel.get_node("BestOreLabel").text = "Best Ore:       " + best_str
	panel.show()

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

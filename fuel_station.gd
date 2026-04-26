extends Node2D

# Holds the player while they are inside the station area.
var _player = null

func _ready() -> void:
	$FuelUI.hide()

func _process(_delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	_player = body
	$FuelUI.show()

func _on_area_2d_body_exited(body: Node2D) -> void:
	_player = null
	$FuelUI.hide()

# Refills as much fuel as the player can afford at $1 per unit.
# Shakes the dialogue red if the player has no cash.
func _on_button_pressed() -> void:
	if _player == null:
		return
	if _player.cash <= 0:
		_shake_no_cash()
		return
	var fuel_needed: int = _player.maxFuel - _player.currentFuel
	if fuel_needed <= 0:
		return
	var fuel_to_add: int = mini(fuel_needed, _player.cash)
	_player.spend_cash(fuel_to_add)
	_player.refill_fuel(fuel_to_add)

# Briefly tints the FuelUI red and shakes it to signal insufficient funds.
# FuelUI is a CanvasLayer: shake via offset, tint via CanvasItem children.
func _shake_no_cash() -> void:
	var ui: CanvasLayer = $FuelUI
	for child in ui.get_children():
		if child is CanvasItem:
			(child as CanvasItem).modulate = Color(1.0, 0.2, 0.2, 1.0)
	var origin: Vector2 = ui.offset
	var tween := create_tween()
	tween.tween_property(ui, "offset", origin + Vector2(10, 0), 0.05)
	tween.tween_property(ui, "offset", origin - Vector2(10, 0), 0.05)
	tween.tween_property(ui, "offset", origin + Vector2(8, 0), 0.04)
	tween.tween_property(ui, "offset", origin - Vector2(8, 0), 0.04)
	tween.tween_property(ui, "offset", origin, 0.04)
	tween.tween_callback(func() -> void:
		for child in ui.get_children():
			if child is CanvasItem:
				create_tween().tween_property(child, "modulate", Color.WHITE, 0.3)
	)

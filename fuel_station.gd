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
func _on_button_pressed() -> void:
	if _player == null:
		return
	var fuel_needed: int = _player.maxFuel - _player.currentFuel
	if fuel_needed <= 0 or _player.cash <= 0:
		return
	# Player can only buy as much fuel as they have cash for.
	var fuel_to_add: int = mini(fuel_needed, _player.cash)
	_player.spend_cash(fuel_to_add)
	_player.refill_fuel(fuel_to_add)

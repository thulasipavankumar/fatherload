extends ProgressBar
@onready var player: CharacterBody2D = $"../../player"

func _ready() -> void:
	player.fuel_changed.connect(update_bar)
	update_bar(player.currentFuel)

func update_bar(new_fuel: int) -> void:
	value = float(new_fuel) / player.maxFuel * 100

extends ProgressBar
@onready var player: CharacterBody2D = $"../../player"

func _ready() -> void:
	player.health_changed.connect(update_bar)
	update_bar(player.health)

func update_bar(new_health: int) -> void:
	value = float(new_health) / player.max_health * 100

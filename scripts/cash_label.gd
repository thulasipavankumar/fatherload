extends Label
@onready var player: CharacterBody2D = $"../../player"

func _ready() -> void:
	player.cash_changed.connect(update_label)
	update_label(player.cash)

func update_label(new_cash: int) -> void:
	text = "Cash: $" + str(new_cash)

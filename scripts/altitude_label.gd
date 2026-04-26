extends Label
@onready var player: CharacterBody2D = $"../../player"

func _process(_delta: float) -> void:
	var depth := int(player._start_position.y/25 - player.position.y/25)
	text = "Depth: " + str(depth) + "m"

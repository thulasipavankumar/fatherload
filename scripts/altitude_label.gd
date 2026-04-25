extends Label
@onready var player: CharacterBody2D = $"../../player"

func _process(_delta: float) -> void:
	var depth := int(player._start_position.y - player.position.y)
	text = "Depth: " + str(depth) + "m"

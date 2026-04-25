extends Label
@onready var player: CharacterBody2D = $"../../player"

func _process(_delta: float) -> void:
	text = "Depth: " + str(maxi(0, int(player.position.y))) + "m"

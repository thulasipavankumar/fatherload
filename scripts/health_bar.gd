extends ProgressBar
@onready var player: CharacterBody2D = $"../../player"

func _ready() -> void:
	show_percentage = false
	var title := Label.new()
	title.text = "HP"
	title.set_anchors_preset(Control.PRESET_FULL_RECT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.offset_left = 4.0
	title.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	add_child(title)

	player.health_changed.connect(update_bar)
	update_bar(player.health)

func update_bar(new_health: int) -> void:
	value = float(new_health) / player.max_health * 100

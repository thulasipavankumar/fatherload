extends ProgressBar
@onready var player: CharacterBody2D = $"../../player"
var _label: Label
var _style_normal: StyleBoxFlat
var _style_danger: StyleBoxFlat

func _ready() -> void:
	_style_normal = StyleBoxFlat.new()
	_style_normal.bg_color = Color(0.2, 0.5, 1, 1)

	_style_danger = StyleBoxFlat.new()
	_style_danger.bg_color = Color(1, 0.2, 0.2, 1)

	_label = Label.new()
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_label)

	player.fuel_changed.connect(update_bar)
	update_bar(player.currentFuel)

func update_bar(new_fuel: int) -> void:
	value = float(new_fuel) / player.maxFuel * 100
	_label.text = str(new_fuel)
	add_theme_stylebox_override("fill", _style_danger if new_fuel <= 20 else _style_normal)

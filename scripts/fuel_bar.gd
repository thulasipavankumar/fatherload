extends ProgressBar
@onready var player: CharacterBody2D = $"../../player"
var _label: Label

func _ready() -> void:
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

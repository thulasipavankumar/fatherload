extends ProgressBar
@onready var player: CharacterBody2D = $"../../player"
var _label: Label
var _style_normal: StyleBoxFlat
var _style_danger: StyleBoxFlat

var _is_shaking: bool = false
var _shake_time: float = 0.0
var _base_offset_left: float
var _base_offset_right: float
const SHAKE_AMPLITUDE = 4.0
const SHAKE_FREQUENCY = 10.0

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

	_base_offset_left = offset_left
	_base_offset_right = offset_right

	player.fuel_changed.connect(update_bar)
	update_bar(player.currentFuel)

func _process(delta: float) -> void:
	if not _is_shaking:
		return
	_shake_time += delta
	var dx := sin(_shake_time * SHAKE_FREQUENCY * TAU) * SHAKE_AMPLITUDE
	offset_left = _base_offset_left + dx
	offset_right = _base_offset_right + dx

func update_bar(new_fuel: int) -> void:
	value = float(new_fuel) / player.maxFuel * 100
	_label.text = str(new_fuel)
	if new_fuel <= 20:
		add_theme_stylebox_override("fill", _style_danger)
		_is_shaking = true
	else:
		add_theme_stylebox_override("fill", _style_normal)
		if _is_shaking:
			_is_shaking = false
			_shake_time = 0.0
			offset_left = _base_offset_left
			offset_right = _base_offset_right

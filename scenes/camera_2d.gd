extends Camera2D

@export var zoom_speed := 0.1
@export var min_zoom := 0.05
@export var max_zoom := 2.0
@export var pan_speed := 1.0

var dragging := false
var last_mouse_pos := Vector2.ZERO

func _ready() -> void:
	enabled = true

func _process(delta: float) -> void:
	var input := Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if input != Vector2.ZERO:
		position += input.normalized() * 600.0 * delta * zoom.x

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_adjust_zoom(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_adjust_zoom(1)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed
			last_mouse_pos = event.position

	if event is InputEventMouseMotion and dragging:
		position -= (event.position - last_mouse_pos) * pan_speed * zoom.x
		last_mouse_pos = event.position

func _adjust_zoom(direction: int) -> void:
	var z := zoom.x + direction * zoom_speed
	z = clamp(z, min_zoom, max_zoom)
	zoom = Vector2(z, z)

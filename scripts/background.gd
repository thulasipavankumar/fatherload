extends Node2D

@onready var _plane: Sprite2D = $plane

const SPEED_MIN = 60.0
const SPEED_MAX = 130.0
const DELAY_MIN = 5.0
const DELAY_MAX = 18.0

var _speed: float = 0.0
var _delay: float = 0.0
var _active: bool = false
var _screen_width: float = 0.0
var _plane_y: float = 0.0

func _ready() -> void:
	_screen_width = get_viewport_rect().size.x
	_plane_y = _plane.position.y
	#_plane.flip_h = true
	_plane.visible = false
	_delay = randf_range(2.0, 8.0)

func _process(delta: float) -> void:
	if not _active:
		_delay -= delta
		if _delay <= 0.0:
			_start_pass()
		return
	_plane.position.x -= _speed * delta
	if _plane.position.x < -200.0:
		_plane.visible = false
		_active = false
		_delay = randf_range(DELAY_MIN, DELAY_MAX)

func _start_pass() -> void:
	_plane.position.x = _screen_width + 200.0
	_plane.position.y = _plane_y
	_speed = randf_range(SPEED_MIN, SPEED_MAX)
	_plane.visible = true
	_active = true

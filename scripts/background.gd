extends Node2D

@onready var _plane: Sprite2D = $plane

const SPEED_MIN = 60.0
const SPEED_MAX = 130.0
const DELAY_MIN = 5.0
const DELAY_MAX = 18.0
const MAP_WORLD_RIGHT = 5000.0  # 100 tiles x 50px

var _speed: float = 0.0
var _delay: float = 0.0
var _active: bool = false
var _screen_width: float = 0.0
var _plane_y: float = 0.0

func _ready() -> void:
	_screen_width = get_viewport_rect().size.x
	_plane_y = _plane.position.y
	_plane.visible = false
	_delay = randf_range(2.0, 8.0)
	_tile_backgrounds()

func _tile_backgrounds() -> void:
	# Convert map right edge to local x space.
	var right_local := MAP_WORLD_RIGHT - global_position.x + 500.0

	# Ground backdrop strips (background.png, 467px wide, no scale).
	var bg_ref: Sprite2D = $Sprite2D
	var bg_w := float(bg_ref.texture.get_width())
	var x: float = $Sprite2D3.position.x + bg_w
	while x - bg_w * 0.5 < right_local:
		var s := bg_ref.duplicate() as Sprite2D
		s.position.x = x
		add_child(s)
		x += bg_w

	# Sky strips (background-sky.png, 475px wide, z=-2).
	var sky_ref: Sprite2D = $Sprite2D4
	var sky_w := float(sky_ref.texture.get_width())
	x = $Sprite2D6.position.x + sky_w
	while x - sky_w * 0.5 < right_local:
		var s := sky_ref.duplicate() as Sprite2D
		s.position.x = x
		add_child(s)
		x += sky_w

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

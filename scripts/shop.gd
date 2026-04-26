extends Node2D

var _player = null
var _canvas: CanvasLayer = null
var _panel: Panel = null
var _buy_btns: Dictionary = {}

const UPGRADES = [
	{"id": "fuel",   "name": "Fuel Tank",     "desc": "+30 max fuel",      "costs": [150, 300, 600]},
	{"id": "hull",   "name": "Hull Armor",    "desc": "+25 max health",    "costs": [100, 250, 500]},
	{"id": "engine", "name": "Speed Engine",  "desc": "+20 move speed",    "costs": [250, 500]},
	{"id": "drill",  "name": "Drill Bit",     "desc": "+15 drill speed",   "costs": [200, 400]},
]

var _tiers: Dictionary = {}

func _ready() -> void:
	for u in UPGRADES:
		_tiers[u["id"]] = 0
	_build_ui()
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func reset() -> void:
	for u in UPGRADES:
		_tiers[u["id"]] = 0
	_update_buttons()

func _build_ui() -> void:
	_canvas = CanvasLayer.new()
	_canvas.hide()
	add_child(_canvas)

	_panel = Panel.new()
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -190.0
	_panel.offset_right = 190.0
	_panel.offset_top = -230.0
	_panel.offset_bottom = 230.0
	_canvas.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 12.0
	vbox.offset_top = 12.0
	vbox.offset_right = -12.0
	vbox.offset_bottom = -12.0
	_panel.add_child(vbox)

	var title := Label.new()
	title.text = "UPGRADE SHOP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	for u in UPGRADES:
		var hbox := HBoxContainer.new()
		hbox.custom_minimum_size = Vector2(0, 60)
		vbox.add_child(hbox)

		var info := Label.new()
		info.text = u["name"] + "\n" + u["desc"]
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.autowrap_mode = TextServer.AUTOWRAP_WORD
		hbox.add_child(info)

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(90, 0)
		_buy_btns[u["id"]] = btn
		btn.pressed.connect(_on_buy_pressed.bind(u["id"]))
		hbox.add_child(btn)

		vbox.add_child(HSeparator.new())

	var close_btn := Button.new()
	close_btn.text = "Close [E]"
	close_btn.pressed.connect(func() -> void: _canvas.hide())
	vbox.add_child(close_btn)

	_update_buttons()

func _update_buttons() -> void:
	for u in UPGRADES:
		var id: String = u["id"]
		var tier: int = _tiers[id]
		var btn: Button = _buy_btns[id]
		if tier >= u["costs"].size():
			btn.text = "MAX"
			btn.disabled = true
		else:
			btn.text = "$%d" % u["costs"][tier]
			btn.disabled = false

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_player = body
		_update_buttons()
		_canvas.show()

func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		_canvas.hide()

func _on_buy_pressed(id: String) -> void:
	if _player == null:
		return
	var u = _find_upgrade(id)
	if u == null:
		return
	var tier: int = _tiers[id]
	if tier >= u["costs"].size():
		return
	var cost: int = u["costs"][tier]
	if _player.cash < cost:
		_flash_no_cash()
		return
	_player.spend_cash(cost)
	_tiers[id] += 1
	_apply_upgrade(id)
	_update_buttons()

func _apply_upgrade(id: String) -> void:
	match id:
		"fuel":
			_player.upgrade_fuel_tank(30)
		"hull":
			_player.upgrade_hull(25)
		"engine":
			_player.SPEED += 20.0
		"drill":
			_player.MINING_SPEED += 15.0

func _find_upgrade(id: String):
	for u in UPGRADES:
		if u["id"] == id:
			return u
	return null

func _flash_no_cash() -> void:
	if _panel == null:
		return
	_panel.modulate = Color(1.0, 0.3, 0.3, 1.0)
	create_tween().tween_property(_panel, "modulate", Color.WHITE, 0.4)

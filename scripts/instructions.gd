extends CanvasLayer

signal start_pressed

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0.04, 0.04, 0.10, 0.93)
	add_child(bg)

	var panel := Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -390.0
	panel.offset_right = 390.0
	panel.offset_top = -232.0
	panel.offset_bottom = 232.0
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 18.0
	vbox.offset_top = 10.0
	vbox.offset_right = -18.0
	vbox.offset_bottom = -10.0
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "FATHERLOAD  —  How to Play"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rtl.scroll_active = true
	rtl.text = _content()
	vbox.add_child(rtl)

	vbox.add_child(HSeparator.new())

	var btn := Button.new()
	btn.text = "START GAME"
	btn.custom_minimum_size = Vector2(0, 42)
	btn.add_theme_font_size_override("font_size", 16)
	btn.pressed.connect(func() -> void: start_pressed.emit())
	vbox.add_child(btn)

func _content() -> String:
	return (
		"[b][color=#FFD700]CONTROLS[/color][/b]  "
		+ "[color=#88CCFF]A/D[/color] or [color=#88CCFF]←/→[/color] move & drill   "
		+ "[color=#88CCFF]S[/color] or [color=#88CCFF]↓[/color] drill down   "
		+ "[color=#88CCFF]W[/color] or [color=#88CCFF]↑[/color] fly up [color=#888888](tunnels only)[/color]\n"
		+ "[color=#888888]No diagonal movement. Speed slows automatically near solid rock.[/color]\n\n"

		+ "[b][color=#FFD700]FUEL[/color][/b]  "
		+ "Drains over time — [color=#4499FF]blue bar[/color] top-right. "
		+ "Turns [color=#FF4444]red and shakes[/color] when critically low. "
		+ "Refuel at the [b]Fuel Station[/b] (near start) for [b]$10/unit[/b]. "
		+ "[color=#FF5555]Zero fuel → run over.[/color]\n\n"

		+ "[b][color=#FFD700]HEALTH[/color][/b]  "
		+ "[color=#44FF88]Green bar[/color] top-left. "
		+ "[b]Fall damage[/b] triggers on hard landings (pod flashes red). "
		+ "[color=#FF5555]Zero health → run over.[/color]\n\n"

		+ "[b][color=#FFD700]ORES & CASH[/color][/b]  "
		+ "Drill ore tiles to earn cash. "
		+ "[b]Deeper = more valuable.[/b] "
		+ "Coal and Rock near the surface; Diamond, Relic, Treasure far below.\n\n"

		+ "[b][color=#FFD700]UPGRADE SHOP[/color][/b]  "
		+ "Walk [b]right[/b] along the surface. "
		+ "Buy [color=#88FF88]Fuel Tank · Hull Armor · Speed Engine · Drill Bit[/color] upgrades with cash. "
		+ "Resets each run.\n\n"

		+ "[b][color=#FFD700]GOAL[/color][/b]  "
		+ "Drill deep, collect valuable ores, survive. "
		+ "A [b]Run Summary[/b] shows your stats on death — beat your best depth!"
	)

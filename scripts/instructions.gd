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
	panel.offset_left = -370.0
	panel.offset_right = 370.0
	panel.offset_top = -280.0
	panel.offset_bottom = 280.0
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 22.0
	vbox.offset_top = 16.0
	vbox.offset_right = -22.0
	vbox.offset_bottom = -16.0
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "FATHERLOAD"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "How to Play"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	vbox.add_child(subtitle)

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
		"[b][color=#FFD700]  CONTROLS[/color][/b]\n"
		+ "[ul]\n"
		+ "[li][color=#88CCFF]A / D[/color]  or  [color=#88CCFF]← / →[/color]  —  Move and drill left / right[/li]\n"
		+ "[li][color=#88CCFF]S[/color]  or  [color=#88CCFF]↓[/color]  —  Drill downward[/li]\n"
		+ "[li][color=#88CCFF]W[/color]  or  [color=#88CCFF]↑[/color]  —  Fly upward [color=#888888](tunnels and open sky only)[/color][/li]\n"
		+ "[/ul]\n"
		+ "[color=#888888]Horizontal and vertical input are exclusive — no diagonal movement.\n"
		+ "Speed slows automatically when solid rock is directly ahead.[/color]\n\n"

		+ "[b][color=#FFD700]  FUEL[/color][/b]\n"
		+ "[ul]\n"
		+ "[li]Fuel drains over time — watch the [color=#4499FF]blue bar[/color] (top-right).[/li]\n"
		+ "[li]Bar turns [color=#FF4444]red and shakes[/color] when critically low.[/li]\n"
		+ "[li]Visit the [b]Fuel Station[/b] near your start position to refuel at [b]$10/unit[/b].[/li]\n"
		+ "[li][color=#FF5555]Fuel hits zero → run over.[/color][/li]\n"
		+ "[/ul]\n\n"

		+ "[b][color=#FFD700]  HEALTH[/color][/b]\n"
		+ "[ul]\n"
		+ "[li]Watch the [color=#44FF88]green bar[/color] (top-left).[/li]\n"
		+ "[li][b]Fall damage[/b] triggers on hard landings — the pod flashes red.[/li]\n"
		+ "[li][color=#FF5555]Health hits zero → run over.[/color][/li]\n"
		+ "[/ul]\n\n"

		+ "[b][color=#FFD700]  ORES & CASH[/color][/b]\n"
		+ "[ul]\n"
		+ "[li]Drill ore tiles to collect cash — shown at the top-centre.[/li]\n"
		+ "[li][b]Deeper ores are worth more.[/b] Rock and Coal near the surface;\n"
		+ "    Diamond, Relic, and Treasure far below.[/li]\n"
		+ "[/ul]\n\n"

		+ "[b][color=#FFD700]  UPGRADE SHOP[/color][/b]\n"
		+ "[ul]\n"
		+ "[li]Walk [b]right[/b] along the surface to find the Upgrade Shop.[/li]\n"
		+ "[li]Spend cash on [color=#88FF88]Fuel Tank · Hull Armor · Speed Engine · Drill Bit[/color].[/li]\n"
		+ "[li]All upgrades reset at the start of each run.[/li]\n"
		+ "[/ul]\n\n"

		+ "[b][color=#FFD700]  GOAL[/color][/b]\n"
		+ "[ul]\n"
		+ "[li]Drill as deep as possible and collect the most valuable ores.[/li]\n"
		+ "[li]Your [b]Run Summary[/b] shows your stats when you die — beat your best depth![/li]\n"
		+ "[/ul]"
	)

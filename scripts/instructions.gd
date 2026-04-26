extends CanvasLayer

signal start_pressed

func _ready() -> void:
	# Defer so parent sizes are finalised before we build the layout.
	call_deferred("_build_ui")

func _build_ui() -> void:
	const pw := 720.0   # panel width  — narrower than 1280px game viewport
	const ph := 540.0   # panel height — shorter than  720px game viewport

	# ── full-screen dark overlay ──────────────────────────────────────────
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.04, 0.10, 0.93)
	add_child(bg)

	# ── centred panel ────────────────────────────────────────────────────
	var panel := Panel.new()
	panel.anchor_left   = 0.5;  panel.anchor_right  = 0.5
	panel.anchor_top    = 0.5;  panel.anchor_bottom = 0.5
	panel.offset_left   = -pw * 0.5;  panel.offset_right  = pw * 0.5
	panel.offset_top    = -ph * 0.5;  panel.offset_bottom = ph * 0.5
	add_child(panel)

	const MARGIN  := 20.0
	const BTN_H   := 44.0
	const SEP_H   := 10.0
	const TITLE_H := 38.0

	# ── title ────────────────────────────────────────────────────────────
	var title := Label.new()
	title.text = "FATHERLOAD  —  How to Play"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_left   = MARGIN;  title.offset_right  = -MARGIN
	title.offset_top    = MARGIN;  title.offset_bottom = MARGIN + TITLE_H
	panel.add_child(title)

	# ── top separator ────────────────────────────────────────────────────
	var sep_top := HSeparator.new()
	sep_top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sep_top.offset_left  = MARGIN;   sep_top.offset_right  = -MARGIN
	sep_top.offset_top   = MARGIN + TITLE_H + 4.0
	sep_top.offset_bottom = MARGIN + TITLE_H + 4.0 + SEP_H
	panel.add_child(sep_top)

	# ── bottom separator + start button (fixed at bottom) ────────────────
	var sep_bot := HSeparator.new()
	sep_bot.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	sep_bot.offset_left   = MARGIN;  sep_bot.offset_right  = -MARGIN
	sep_bot.offset_bottom = -MARGIN - BTN_H - 6.0
	sep_bot.offset_top    = -MARGIN - BTN_H - 6.0 - SEP_H
	panel.add_child(sep_bot)

	var btn := Button.new()
	btn.text = "START GAME"
	btn.add_theme_font_size_override("font_size", 16)
	btn.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	btn.offset_left   = MARGIN + (pw - 2*MARGIN) * 0.25
	btn.offset_right  = -MARGIN - (pw - 2*MARGIN) * 0.25
	btn.offset_bottom = -MARGIN
	btn.offset_top    = -MARGIN - BTN_H
	btn.pressed.connect(func() -> void: start_pressed.emit())
	panel.add_child(btn)

	# ── scrollable rich-text content fills the remaining middle space ─────
	var rtl_top    := MARGIN + TITLE_H + 4.0 + SEP_H + 4.0
	var rtl_bottom := -(MARGIN + BTN_H + 6.0 + SEP_H + 4.0)

	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled  = true
	rtl.scroll_active   = true
	rtl.fit_content     = false
	rtl.anchor_left     = 0.0;  rtl.anchor_right  = 1.0
	rtl.anchor_top      = 0.0;  rtl.anchor_bottom = 1.0
	rtl.offset_left     = MARGIN
	rtl.offset_right    = -MARGIN
	rtl.offset_top      = rtl_top
	rtl.offset_bottom   = rtl_bottom
	rtl.text            = _content()
	panel.add_child(rtl)

func _content() -> String:
	return (
		"[b][color=#FFD700]CONTROLS[/color][/b]\n"
		+ "  [color=#88CCFF]A / D[/color]  or  [color=#88CCFF]← / →[/color]   Move and drill left / right\n"
		+ "  [color=#88CCFF]S[/color]  or  [color=#88CCFF]↓[/color]              Drill downward\n"
		+ "  [color=#88CCFF]W[/color]  or  [color=#88CCFF]↑[/color]              Fly upward [color=#888888](tunnels and open sky only)[/color]\n"
		+ "[color=#888888]  No diagonal movement. Speed slows automatically when solid rock is ahead.[/color]\n\n"

		+ "[b][color=#FFD700]FUEL[/color][/b]\n"
		+ "  Drains over time — watch the [color=#4499FF]blue bar[/color] top-right.\n"
		+ "  Bar turns [color=#FF4444]red and shakes[/color] when critically low.\n"
		+ "  Refuel at the [b]Fuel Station[/b] near your start position — [b]$10 per unit[/b].\n"
		+ "  [color=#FF5555]Fuel hits zero → run over.[/color]\n\n"

		+ "[b][color=#FFD700]HEALTH[/color][/b]\n"
		+ "  Watch the [color=#44FF88]green bar[/color] top-left.\n"
		+ "  [b]Fall damage[/b] triggers on hard landings — the pod flashes red.\n"
		+ "  [color=#FF5555]Health hits zero → run over.[/color]\n\n"

		+ "[b][color=#FFD700]ORES & CASH[/color][/b]\n"
		+ "  Drill ore tiles to earn cash, shown at the top-centre.\n"
		+ "  [b]Deeper = more valuable.[/b] Coal and Rock near the surface;\n"
		+ "  Diamond, Relic, and Treasure far below.\n\n"

		+ "[b][color=#FFD700]UPGRADE SHOP[/color][/b]\n"
		+ "  Walk [b]right[/b] along the surface to find the Upgrade Shop.\n"
		+ "  Spend cash on [color=#88FF88]Fuel Tank · Hull Armor · Speed Engine · Drill Bit[/color].\n"
		+ "  All upgrades reset at the start of each run.\n\n"

		+ "[b][color=#FFD700]GOAL[/color][/b]\n"
		+ "  Drill as deep as possible and collect the most valuable ores.\n"
		+ "  A [b]Run Summary[/b] shows your stats on death — beat your best depth!"
	)

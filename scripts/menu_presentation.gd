extends RefCounted
## Presentation for the existing main menu; gameplay stays in game.gd.

const DESIGN_SIZE := Vector2(1280, 720)
const TITLE_FONT = preload("res://assets/menu/Fredoka.ttf")
const UI_FONT = preload("res://assets/menu/Nunito.ttf")
const BUTTON_SKIN = preload("res://assets/menu/menu_button.svg")
const VELORA_MARK = preload("res://assets/menu/velora_mark.svg")

class StaticAccents extends Control:
	func _draw() -> void:
		# A stationary contact shadow anchors Bit to the grassy ledge.
		draw_set_transform(Vector2(245, 513), 0.0, Vector2(1.0, 0.15))
		draw_circle(Vector2.ZERO, 71.0, Color(0.07, 0.24, 0.24, 0.16))
		draw_set_transform(Vector2.ZERO)
		for spec in [Vector3(395, 85, 13), Vector3(881, 105, 9)]:
			var points := PackedVector2Array()
			for i in 8:
				var angle := -PI * 0.5 + i * PI * 0.25
				var radius: float = spec.z * (1.0 if i % 2 == 0 else 0.28)
				points.append(Vector2(spec.x, spec.y) + Vector2.from_angle(angle) * radius)
			draw_colored_polygon(points, Color("fff0ad"))
			draw_polyline(points + PackedVector2Array([points[0]]), Color("537e8b"), 1.3, true)

static func font(base: Font, weight: float) -> FontVariation:
	var result := FontVariation.new()
	result.base_font = base
	result.variation_opentype = {0x77676874: weight}
	return result

static func label(parent: Node, text: String, rect: Rect2, typeface: Font, font_size: int, color: Color) -> Label:
	var result := Label.new()
	result.text = text
	result.position = rect.position
	result.size = rect.size
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result.add_theme_font_override("font", typeface)
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	parent.add_child(result)
	return result

static func panel(color: Color, border: Color, radius: int) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = color
	result.border_color = border
	result.set_border_width_all(2)
	result.set_corner_radius_all(radius)
	result.shadow_color = Color(0.03, 0.13, 0.22, 0.18)
	result.shadow_size = 5
	result.shadow_offset = Vector2(0, 3)
	return result

static func button_style(color: Color) -> StyleBoxTexture:
	var result := StyleBoxTexture.new()
	result.texture = BUTTON_SKIN
	result.modulate_color = color
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		result.set_texture_margin(side, 25.0)
	result.content_margin_left = 26.0
	result.content_margin_right = 26.0
	result.content_margin_top = 7.0
	result.content_margin_bottom = 13.0
	return result

static func icon(kind: String) -> Texture2D:
	var shapes := {
		"new": '<path d="M11 6L27 16L11 26Z" fill="#234967" stroke="#234967" stroke-width="3" stroke-linejoin="round"/>',
		"continue": '<path d="M7 11A11 11 0 1 1 5 21M7 4V11H14M16 9V16L21 19" fill="none" stroke="#234967" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>',
		"selection": '<g fill="#234967"><rect x="4" y="4" width="10" height="10" rx="3"/><rect x="18" y="4" width="10" height="10" rx="3"/><rect x="4" y="18" width="10" height="10" rx="3"/><rect x="18" y="18" width="10" height="10" rx="3"/></g>',
		"settings": '<g fill="none" stroke="#234967" stroke-width="3" stroke-linecap="round"><circle cx="16" cy="16" r="8"/><path d="M16 3V7M16 25V29M3 16H7M25 16H29M7 7L10 10M22 22L25 25M7 25L10 22M22 10L25 7"/><circle cx="16" cy="16" r="2"/></g>',
		"credits": '<path d="M16 28L5 18C-3 10 8 0 16 9C24 0 35 10 27 18Z" fill="#234967"/>'
	}
	var svg: String = '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">' + shapes[kind] + '</svg>'
	var bitmap := Image.new()
	bitmap.load_svg_from_string(svg, 2.0)
	return ImageTexture.create_from_image(bitmap)

static func make_button(text: String, key: String, action: Callable, color: Color, primary: bool) -> Button:
	var result := Button.new()
	result.name = key.capitalize().replace(" ", "") + "Button"
	result.text = text
	result.custom_minimum_size = Vector2(440, 66 if primary else 62)
	result.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	result.add_theme_font_override("font", font(UI_FONT, 850.0))
	result.add_theme_font_size_override("font_size", 27 if primary else 25)
	result.add_theme_color_override("font_color", Color("234967"))
	result.add_theme_color_override("font_hover_color", Color("173e5a"))
	result.add_theme_color_override("font_pressed_color", Color("173e5a"))
	result.add_theme_color_override("font_focus_color", Color("173e5a"))
	result.add_theme_color_override("font_disabled_color", Color("54707f"))
	result.add_theme_stylebox_override("normal", button_style(color))
	result.add_theme_stylebox_override("hover", button_style(color.lightened(0.10)))
	result.add_theme_stylebox_override("pressed", button_style(color.darkened(0.07)))
	result.add_theme_stylebox_override("disabled", button_style(Color("c6dce3")))
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.set_corner_radius_all(22)
	focus.set_border_width_all(3)
	focus.border_color = Color("fff5b2")
	result.add_theme_stylebox_override("focus", focus)
	result.icon = icon(key)
	result.expand_icon = true
	result.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	result.add_theme_constant_override("icon_max_width", 25)
	result.add_theme_color_override("icon_disabled_color", Color(1, 1, 1, 0.42))
	result.pressed.connect(func():
		Progress.sfx("ui")
		action.call()
	)
	return result

static func build(screen: Control, bit_texture: Texture2D, star_texture: Texture2D, actions: Dictionary, can_continue: bool) -> TextureRect:
	var canvas := Control.new()
	canvas.name = "MainMenuPresentation"
	canvas.size = DESIGN_SIZE
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(canvas)
	var fit := func():
		var factor := minf(screen.size.x / DESIGN_SIZE.x, screen.size.y / DESIGN_SIZE.y)
		canvas.scale = Vector2.ONE * factor
		canvas.position = (screen.size - DESIGN_SIZE * factor) * 0.5
	screen.resized.connect(fit)
	fit.call()
	var accents := StaticAccents.new()
	accents.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(accents)

	var headline := font(TITLE_FONT, 700.0)
	var title_size := 105
	var first_width := headline.get_string_size("STAR", HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x
	var full_width := first_width + headline.get_string_size("BIT", HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x
	var start := (DESIGN_SIZE.x - full_width) * 0.5
	for part in [["STAR", start, Color("ffe28a")], ["BIT", start + first_width, Color("8ce5f6")]]:
		var rect := Rect2(part[1], 21, 360, 132)
		var rim := label(canvas, part[0], rect, headline, title_size, Color("fff8dc"))
		rim.add_theme_constant_override("outline_size", 16)
		rim.add_theme_color_override("font_outline_color", Color("fff8dc"))
		rim.add_theme_color_override("font_shadow_color", Color("285775"))
		rim.add_theme_constant_override("shadow_offset_y", 6)
		rim.add_theme_constant_override("shadow_outline_size", 18)
		var face := label(canvas, part[0], rect, headline, title_size, part[2])
		face.name = "Title" + str(part[0])
		face.add_theme_color_override("font_outline_color", Color("245675"))
		face.add_theme_constant_override("outline_size", 5)

	var ribbon := Panel.new()
	ribbon.name = "SubtitleRibbon"
	ribbon.position = Vector2(471, 159)
	ribbon.size = Vector2(338, 42)
	ribbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ribbon.add_theme_stylebox_override("panel", panel(Color(0.07, 0.24, 0.33, 0.9), Color("e7f7db"), 21))
	canvas.add_child(ribbon)
	var subtitle := label(ribbon, "Království snů", Rect2(0, 0, 338, 42), font(UI_FONT, 850.0), 26, Color("fff3c5"))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var hero := TextureRect.new()
	hero.name = "MenuBit"
	hero.texture = bit_texture
	hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero.position = Vector2(110, 211)
	hero.size = Vector2(270, 300)
	hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(hero)
	var star := TextureRect.new()
	star.name = "MenuJiskra"
	star.texture = star_texture
	star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	star.position = Vector2(976, 270)
	star.size = Vector2(154, 154)
	star.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(star)

	var buttons := VBoxContainer.new()
	buttons.name = "MenuButtons"
	buttons.position = Vector2(420, 226)
	buttons.size = Vector2(440, 364)
	buttons.add_theme_constant_override("separation", 10)
	canvas.add_child(buttons)
	var focusable: Array[Button] = []
	for spec in [["Nová hra", "new", "ffe08b"], ["Pokračovat", "continue", "95dcf6"], ["Výběr levelu", "selection", "b4efd1"], ["Nastavení", "settings", "d8c6f8"], ["Autoři", "credits", "f8c2d3"]]:
		var item := make_button(spec[0], spec[1], actions[spec[1]], Color(spec[2]), spec[1] == "new")
		item.disabled = spec[1] == "continue" and not can_continue
		buttons.add_child(item)
		if not item.disabled:
			focusable.append(item)
	for i in focusable.size():
		var previous := focusable[posmod(i - 1, focusable.size())]
		var next := focusable[(i + 1) % focusable.size()]
		focusable[i].focus_neighbor_top = focusable[i].get_path_to(previous)
		focusable[i].focus_neighbor_bottom = focusable[i].get_path_to(next)
		focusable[i].focus_previous = focusable[i].get_path_to(previous)
		focusable[i].focus_next = focusable[i].get_path_to(next)

	var credit := Panel.new()
	credit.name = "VeloraCredit"
	credit.position = Vector2(477, 627)
	credit.size = Vector2(326, 66)
	credit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	credit.add_theme_stylebox_override("panel", panel(Color(0.04, 0.17, 0.25, 0.94), Color(0.66, 0.93, 0.86, 0.78), 22))
	canvas.add_child(credit)
	var mark := TextureRect.new()
	mark.name = "VeloraLogo"
	mark.texture = VELORA_MARK
	mark.position = Vector2(14, 5)
	mark.size = Vector2(56, 56)
	mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	credit.add_child(mark)
	label(credit, "A game by", Rect2(88, 5, 214, 24), font(UI_FONT, 650.0), 16, Color("c6e9dd"))
	label(credit, "VELORA", Rect2(86, 22, 218, 39), font(TITLE_FONT, 600.0), 30, Color("fff0be"))
	return hero

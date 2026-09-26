extends Control
## Manual story pages. The controller pauses only the current level, not this UI.
signal finished

const MOLE = preload("res://assets/animations/mole.tres")
const FONT = preload("res://assets/menu/Nunito.ttf")
const BUTTON_ART = preload("res://assets/menu/pause/yellow.svg")
const DESIGN_SIZE = Vector2(1280, 720)
const LETTERS_PER_SECOND := 42.0

var pages := PackedStringArray()
var page_index := 0
var content: Label
var page_label: Label
var confirm: Button
var portrait: AnimatedSprite2D
var canvas: Control
var progress := 0.0
var keyboard_down := false
var closing := false
var press_guard := 0.18
var last_sound := -1
var motion: Tween
var last_button_text := "Vyrazit!"

func setup(message: String, speaker_name: String = "Krteček", frames: SpriteFrames = null, portrait_material: Material = null, finish_text: String = "Vyrazit!") -> void:
	name = "MoleDialogue"
	last_button_text = finish_text
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	for paragraph in message.split("\n\n", false):
		var clean := paragraph.strip_edges().trim_prefix("Krteček: ")
		if not clean.is_empty():pages.append(clean)
	var shade := ColorRect.new()
	shade.color = Color(0.03, 0.12, 0.23, 0.20)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	canvas = Control.new()
	canvas.size = DESIGN_SIZE
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	_panel(Rect2(96, 397, 1088, 299), Color("fff8e7"))
	_panel(Rect2(119, 431, 166, 220), Color("d7f3e8"))
	portrait = AnimatedSprite2D.new()
	portrait.sprite_frames = frames if frames != null else MOLE
	portrait.material = portrait_material
	portrait.position = Vector2(202, 539)
	portrait.scale = Vector2.ONE * 0.34
	canvas.add_child(portrait)
	_label(speaker_name, Rect2(316, 415, 690, 44), 30, Color("26745d"))
	page_label = _label("", Rect2(1050, 420, 104, 34), 20, Color("527186"))
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	content = _label("", Rect2(316, 468, 834, 136), 28, Color("203e57"))
	content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label("Enter / mezerník nebo tlačítko", Rect2(316, 636, 505, 34), 18, Color("527186"))
	confirm = ConfirmButton.new()
	confirm.name = "ConfirmDialogue"
	confirm.position = Vector2(876, 618)
	confirm.size = Vector2(278, 62)
	confirm.custom_minimum_size = confirm.size
	confirm.pivot_offset = confirm.size * 0.5
	confirm.focus_mode = Control.FOCUS_NONE
	confirm.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	confirm.add_theme_font_override("font", _font(850))
	confirm.add_theme_font_size_override("font_size", 24)
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var skin := StyleBoxTexture.new()
		skin.texture = BUTTON_ART
		skin.set_texture_margin(SIDE_LEFT, 44)
		skin.set_texture_margin(SIDE_RIGHT, 44)
		skin.content_margin_left = 26
		skin.content_margin_right = 26
		skin.content_margin_top = 4
		skin.content_margin_bottom = 10
		confirm.add_theme_stylebox_override(state, skin)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
		confirm.add_theme_color_override(color_name, Color("642704"))
	confirm.button_down.connect(func(): _press(true))
	confirm.button_up.connect(func(): _press(false))
	confirm.pressed.connect(_advance)
	canvas.add_child(confirm)
	resized.connect(_fit)
	_fit()
	_show_page()

func _font(weight: float) -> FontVariation:
	var typeface := FontVariation.new()
	typeface.base_font = FONT
	typeface.variation_opentype = {0x77676874: weight}
	return typeface

func _label(text: String, bounds: Rect2, font_size: int, ink: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = bounds.position
	label.size = bounds.size
	label.add_theme_font_override("font", _font(700))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", ink)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(label)
	return label

func _panel(bounds: Rect2, fill: Color) -> void:
	var panel := Panel.new()
	panel.position = bounds.position
	panel.size = bounds.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = Color("fffef5")
	style.set_border_width_all(3)
	style.set_corner_radius_all(26)
	style.shadow_color = Color(0.04, 0.15, 0.25, 0.28)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 5)
	panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(panel)

func _fit() -> void:
	if canvas == null:return
	var factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size - DESIGN_SIZE * factor) * 0.5

func _show_page() -> void:
	progress = 0.0
	last_sound = -1
	press_guard = 0.18
	content.text = pages[page_index]
	content.visible_characters = 0
	page_label.text = "%d / %d" % [page_index + 1, pages.size()]
	confirm.text = "Zobrazit vše"
	portrait.play("talk" if portrait.sprite_frames.has_animation("talk") else "idle")

func _process(delta: float) -> void:
	press_guard = maxf(0.0, press_guard - delta)
	if content == null or closing or content.visible_characters < 0:return
	progress += delta * LETTERS_PER_SECOND
	content.visible_characters = mini(int(progress), content.get_total_character_count())
	if content.visible_characters >= content.get_total_character_count():
		_reveal()
		return
	var sound_index := floori(progress / 4.0)
	if sound_index > last_sound:
		last_sound = sound_index
		if not content.text.substr(int(progress), 1).strip_edges().is_empty():Progress.sfx("voice_mole")

func _reveal() -> void:
	content.visible_characters = -1
	confirm.text = last_button_text if page_index == pages.size() - 1 else "Další"
	portrait.play("idle")

func _advance() -> void:
	if closing or press_guard > 0:return
	press_guard = 0.18
	Progress.sfx("ui")
	# One confirmation can only reveal OR advance, never both.
	if content.visible_characters >= 0:
		_reveal()
	elif page_index + 1 < pages.size():
		page_index += 1
		_show_page()
	else:
		closing = true
		confirm.disabled = true
		finished.emit()

func _input(event: InputEvent) -> void:
	if closing:return
	if event.is_action("ui_cancel"):
		get_viewport().set_input_as_handled()
		return
	if not (event.is_action("ui_accept") or event.is_action("jump")):return
	get_viewport().set_input_as_handled()
	if event.is_echo():return
	if event.is_pressed():
		keyboard_down = true
		_press(true)
	elif keyboard_down:
		# Release first, so confirming cannot carry a jump into the resumed level.
		keyboard_down = false
		_press(false)
		_advance()

func _press(down: bool) -> void:
	if motion:motion.kill()
	motion = create_tween()
	motion.tween_property(confirm, "scale", Vector2.ONE * (0.97 if down else 1.0), 0.10)

class ConfirmButton extends Button:
	func _has_point(point: Vector2) -> bool:
		return Rect2(Vector2.ZERO, size).has_point(pivot_offset + (point - pivot_offset) * scale)

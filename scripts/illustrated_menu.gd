extends Control
## Main menu: original artwork, with real buttons aligned in image coordinates.

const ARTWORK = preload("res://assets/menu/starbit_illustrated_menu.png")
const FEEDBACK_SHADER = preload("res://shaders/menu_button_feedback.gdshader")
const REWARDS_BUTTON = preload("res://assets/menu/pause/purple.svg")
const REWARDS_FONT = preload("res://assets/menu/pause/Nunito.ttf")
const REWARDS_STAR = preload("res://assets/menu/pause/star.svg")
const DESIGN_SIZE = Vector2(1672.0, 941.0)
const BUTTONS = [
	["new", "NewButton", "Nová hra", Rect2(630, 311, 414, 95)],
	["continue", "ContinueButton", "Pokračovat", Rect2(630, 417, 414, 92)],
	["settings", "SettingsButton", "Nastavení", Rect2(637, 523, 398, 88)],
	["rewards", "RewardsButton", "Odměny", Rect2(651, 622, 370, 83)],
	["quit", "QuitButton", "Konec", Rect2(657, 711, 360, 80)],
]

var canvas: Control
var buttons: Array[ArtButton] = []
var busy := false

func setup(actions: Dictionary, can_continue: bool) -> void:
	name = "IllustratedMenu"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var surround := ColorRect.new()
	surround.color = Color("88caff")
	surround.mouse_filter = Control.MOUSE_FILTER_IGNORE
	surround.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(surround)
	canvas = Control.new()
	canvas.name = "MenuCanvas"
	canvas.size = DESIGN_SIZE
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	var picture := TextureRect.new()
	picture.name = "MenuArtwork"
	picture.texture = ARTWORK
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.size = DESIGN_SIZE
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(picture)
	for spec in BUTTONS:
		var item := ArtButton.new()
		item.name = spec[1]
		item.text = spec[2]
		var bounds: Rect2 = spec[3]
		item.position = bounds.position
		item.size = bounds.size
		item.disabled = spec[0] == "continue" and not can_continue
		item.tooltip_text = "Nejprve začni novou hru." if item.disabled else ""
		canvas.add_child(item)
		item.prepare(FEEDBACK_SHADER, spec[0] == "rewards")
		var action: Callable = actions[spec[0]]
		item.pressed.connect(_activate.bind(item, action))
		buttons.append(item)
	var enabled: Array[ArtButton] = []
	for item in buttons:
		if not item.disabled:
			enabled.append(item)
	for i in enabled.size():
		var previous: NodePath = enabled[i].get_path_to(enabled[posmod(i - 1, enabled.size())])
		var next: NodePath = enabled[i].get_path_to(enabled[(i + 1) % enabled.size()])
		enabled[i].focus_neighbor_top = previous
		enabled[i].focus_previous = previous
		enabled[i].focus_neighbor_bottom = next
		enabled[i].focus_next = next
	resized.connect(_fit)
	_fit()

func _fit() -> void:
	if canvas == null:
		return
	var factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size - DESIGN_SIZE * factor) * 0.5

func _activate(item: ArtButton, action: Callable) -> void:
	if busy or item.disabled:
		return
	busy = true
	for other in buttons:
		other.locked = true
	Progress.sfx("ui")
	item.play_activation(action)

class ArtButton extends Button:
	var feedback: ShaderMaterial
	var hover_tween: Tween
	var press_tween: Tween
	var pointer_inside := false
	var locked := false
	var hover_value := 0.0:
		set(value):
			hover_value = value
			if feedback:
				feedback.set_shader_parameter("hover_amount", value)
	var press_value := 0.0:
		set(value):
			press_value = value
			if feedback:
				feedback.set_shader_parameter("press_amount", value)
	var sweep_value := -1.0:
		set(value):
			sweep_value = value
			if feedback:
				feedback.set_shader_parameter("sweep", value)

	func prepare(shader: Shader, show_caption := false) -> void:
		mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
		focus_mode = Control.FOCUS_NONE if disabled else Control.FOCUS_ALL
		# Caption remains available to accessibility; the illustration supplies visible text.
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
			add_theme_stylebox_override(state, StyleBoxEmpty.new())
		for key in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_disabled_color", "font_focus_color", "font_outline_color"]:
			add_theme_color_override(key, Color.TRANSPARENT)
		add_theme_constant_override("outline_size", 0)
		if show_caption:
			# Cover the old baked-in Autoři caption with the existing glossy skin.
			var style := StyleBoxTexture.new()
			style.texture = REWARDS_BUTTON
			style.set_texture_margin(SIDE_LEFT, 44)
			style.set_texture_margin(SIDE_RIGHT, 44)
			style.content_margin_bottom = 6
			for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
				add_theme_stylebox_override(state, style)
			var typeface := FontVariation.new()
			typeface.base_font = REWARDS_FONT
			typeface.variation_opentype = {0x77676874: 950.0}
			add_theme_font_override("font", typeface)
			add_theme_font_size_override("font_size", 43)
			for key in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
				add_theme_color_override(key, Color("421070"))
			for i in 2:
				var star := TextureRect.new()
				star.texture = REWARDS_STAR
				star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				star.size = Vector2(29,29)
				star.position = Vector2(24 if i == 0 else size.x-53, (size.y-29)*0.5-3)
				star.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(star)
		feedback = ShaderMaterial.new()
		feedback.shader = shader
		feedback.set_shader_parameter("button_size", size)
		feedback.set_shader_parameter("hover_amount", hover_value)
		feedback.set_shader_parameter("press_amount", press_value)
		feedback.set_shader_parameter("sweep", sweep_value)
		var overlay := ColorRect.new()
		overlay.name = "PressFeedback"
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.material = feedback
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(overlay)
		mouse_entered.connect(func(): pointer_inside = true; _refresh_hover())
		mouse_exited.connect(func(): pointer_inside = false; _refresh_hover())
		focus_entered.connect(_refresh_hover)
		focus_exited.connect(_refresh_hover)
		button_down.connect(func(): _press_to(1.0))
		button_up.connect(func(): _press_to(0.0))

	func _has_point(point: Vector2) -> bool:
		var radius := size.y * 0.5
		var closest := Vector2(clampf(point.x, radius, size.x - radius), radius)
		return point.distance_squared_to(closest) <= radius * radius

	func _refresh_hover() -> void:
		if disabled or locked:
			return
		if hover_tween:
			hover_tween.kill()
		var target := 1.0 if pointer_inside or has_focus() else 0.0
		hover_tween = create_tween()
		hover_tween.tween_property(self, "hover_value", target, 0.12)

	func _press_to(amount: float) -> void:
		if disabled or locked:
			return
		if press_tween:
			press_tween.kill()
		press_tween = create_tween()
		press_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		press_tween.tween_property(self, "press_value", amount, 0.07 if amount > 0.0 else 0.12)

	func play_activation(action: Callable) -> void:
		if press_tween:
			press_tween.kill()
		press_tween = create_tween()
		press_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		press_tween.tween_property(self, "press_value", 1.0, 0.045)
		press_tween.tween_property(self, "press_value", 0.0, 0.18)
		press_tween.parallel().tween_property(self, "sweep_value", 1.35, 0.20).from(-0.25).set_trans(Tween.TRANS_LINEAR)
		press_tween.tween_callback(action)

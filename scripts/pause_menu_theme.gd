extends RefCounted
## Reusable pause buttons in the same glossy style as the illustrated main menu.

const FONT = preload("res://assets/menu/pause/Nunito.ttf")
const STAR = preload("res://assets/menu/pause/star.svg")
const FEEDBACK = preload("res://shaders/menu_button_feedback.gdshader")
const SKINS = {
	"blue": preload("res://assets/menu/pause/blue.svg"),
	"yellow": preload("res://assets/menu/pause/yellow.svg"),
	"green": preload("res://assets/menu/pause/green.svg"),
	"purple": preload("res://assets/menu/pause/purple.svg"),
}
const INKS = {
	"blue": Color("073674"), "yellow": Color("642704"),
	"green": Color("075441"), "purple": Color("421070"),
}

static func button(caption: String, action: Callable, palette: String) -> Button:
	var result := DreamButton.new()
	result.text = caption
	result.callback = action
	result.custom_minimum_size = Vector2(432, 76)
	result.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var typeface := FontVariation.new()
	typeface.base_font = FONT
	typeface.variation_opentype = {0x77676874: 950.0}
	result.add_theme_font_override("font", typeface)
	result.add_theme_font_size_override("font_size", 28)
	for key in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		result.add_theme_color_override(key, INKS[palette])
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var style := StyleBoxTexture.new()
		style.texture = SKINS[palette]
		style.set_texture_margin(SIDE_LEFT, 44.0)
		style.set_texture_margin(SIDE_RIGHT, 44.0)
		style.content_margin_left = 58.0
		style.content_margin_right = 58.0
		style.content_margin_top = 5.0
		style.content_margin_bottom = 11.0
		result.add_theme_stylebox_override(state, style)
	result.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return result

class DreamButton extends Button:
	var callback: Callable
	var feedback: ShaderMaterial
	var motion: Tween
	var glow: Tween
	var activated := false
	var hovered := false
	var accents: Array[TextureRect] = []
	var highlight := 0.0:
		set(value):
			highlight = value
			if feedback:
				feedback.set_shader_parameter("hover_amount", value)
	var pressure := 0.0:
		set(value):
			pressure = value
			if feedback:
				feedback.set_shader_parameter("press_amount", value)
	var gleam := -1.0:
		set(value):
			gleam = value
			if feedback:
				feedback.set_shader_parameter("sweep", value)

	func _ready() -> void:
		for i in 2:
			var star := TextureRect.new()
			star.texture = STAR
			star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			star.size = Vector2(27, 27)
			star.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(star)
			accents.append(star)
		feedback = ShaderMaterial.new()
		feedback.shader = FEEDBACK
		feedback.set_shader_parameter("hover_amount", 0.0)
		feedback.set_shader_parameter("press_amount", 0.0)
		feedback.set_shader_parameter("sweep", -1.0)
		var shine := ColorRect.new()
		shine.material = feedback
		shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
		shine.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(shine)
		resized.connect(_layout)
		_layout()
		mouse_entered.connect(func(): hovered = true; _highlight())
		mouse_exited.connect(func(): hovered = false; _highlight())
		focus_entered.connect(_highlight)
		focus_exited.connect(_highlight)
		button_down.connect(func(): _press(true))
		button_up.connect(func(): _press(false))
		pressed.connect(_activate)

	func _has_point(point: Vector2) -> bool:
		# Keep the original click area while only the visual shrinks under the pointer.
		var unscaled_point := pivot_offset + (point - pivot_offset) * scale
		return Rect2(Vector2.ZERO, size).has_point(unscaled_point)

	func _layout() -> void:
		pivot_offset = size * 0.5
		for i in accents.size():
			accents[i].position = Vector2(24.0 if i == 0 else size.x - 51.0, (size.y - 27.0) * 0.5 - 3.0)
		if feedback:
			feedback.set_shader_parameter("button_size", size)

	func _highlight() -> void:
		if activated or disabled:
			return
		if glow:
			glow.kill()
		glow = create_tween()
		glow.tween_property(self, "highlight", 1.0 if hovered or has_focus() else 0.0, 0.12)

	func _press(down: bool) -> void:
		if activated or disabled:
			return
		if motion:
			motion.kill()
		motion = create_tween().set_parallel()
		motion.tween_property(self, "scale", Vector2.ONE * (0.97 if down else 1.0), 0.08 if down else 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		motion.tween_property(self, "pressure", 1.0 if down else 0.0, 0.08 if down else 0.15)

	func _activate() -> void:
		if activated or disabled:
			return
		# One action per panel; the short feedback finishes before changing the screen.
		for sibling in get_parent().get_children():
			if sibling is DreamButton:
				sibling.activated = true
		Progress.sfx("ui")
		if motion:
			motion.kill()
		scale = Vector2.ONE * 0.97
		pressure = 1.0
		motion = create_tween().set_parallel()
		motion.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		motion.tween_property(self, "pressure", 0.0, 0.16)
		motion.tween_property(self, "gleam", 1.35, 0.18).from(-0.25)
		motion.chain().tween_callback(callback)

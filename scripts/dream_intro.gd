extends Control
## A self-contained opening: the owner starts gameplay after `finished`.
## F6 previews only this scene; its final black frame intentionally stays in place.
## All story/fade timing is process-driven, so suspending processing freezes it.

signal finished

const PAUSE_THEME = preload("res://scripts/pause_menu_theme.gd")
const DARKNESS_SHADER = preload("res://shaders/dream_intro_darkness.gdshader")
const JISKRA = preload("res://assets/pieces/jiskra.png")
const FREDOKA = preload("res://assets/menu/Fredoka.ttf")
const NUNITO = preload("res://assets/menu/Nunito.ttf")
const STORY_LENGTH := 9.5
const SKIP_GUARD := 0.5
const SKIP_FADE := 0.35

@export_range(7.0, 18.0, 0.1) var duration_seconds := 9.5
@export var kingdom_texture: Texture2D = preload("res://assets/environments/near_castle.png")

var elapsed := 0.0
var is_finished := false
var _skipping := false
var _skip_elapsed := 0.0
var _skip_from := 0.0
var _kingdom: TextureRect
var _kingdom_material: ShaderMaterial
var _jiskra: TextureRect
var _light: DreamLight
var _caption: Label
var _skip_button: Button
var _hint: Label
var _black: ColorRect
var _ui_scale := 1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_scene()
	resized.connect(_layout)
	_layout()
	_render_frame()


func _build_scene() -> void:
	var base := ColorRect.new()
	base.color = Color("18112b")
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base)
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_kingdom = TextureRect.new()
	_kingdom.name = "PaintedKingdom"
	_kingdom.texture = kingdom_texture
	_kingdom.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_kingdom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_kingdom_material = ShaderMaterial.new()
	_kingdom_material.shader = DARKNESS_SHADER
	_kingdom.material = _kingdom_material
	add_child(_kingdom)

	_light = DreamLight.new()
	_light.name = "WarmSparkles"
	add_child(_light)
	_jiskra = TextureRect.new()
	_jiskra.name = "Jiskra"
	_jiskra.texture = JISKRA
	_jiskra.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_jiskra.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_jiskra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_jiskra)

	_caption = Label.new()
	_caption.name = "StoryCaption"
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption.add_theme_font_override("font", FREDOKA)
	_caption.add_theme_color_override("font_color", Color("fff5d5"))
	_caption.add_theme_color_override("font_outline_color", Color(0.075, 0.035, 0.17, 0.82))
	_caption.add_theme_constant_override("outline_size", 7)
	_caption.add_theme_color_override("font_shadow_color", Color(0.02, 0.01, 0.08, 0.50))
	_caption.add_theme_constant_override("shadow_offset_y", 3)
	add_child(_caption)

	_skip_button = PAUSE_THEME.button("Přeskočit", skip, "blue")
	_skip_button.name = "SkipButton"
	_skip_button.custom_minimum_size = Vector2(218, 62)
	_skip_button.focus_mode = Control.FOCUS_NONE
	_skip_button.disabled = true
	add_child(_skip_button)
	_hint = Label.new()
	_hint.text = "Enter / Esc"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.add_theme_font_override("font", NUNITO)
	_hint.add_theme_color_override("font_color", Color(1.0, 0.96, 0.87, 0.82))
	_hint.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.17, 0.55))
	_hint.add_theme_constant_override("outline_size", 4)
	_hint.visible = not DisplayServer.is_touchscreen_available()
	add_child(_hint)

	_black = ColorRect.new()
	_black.name = "TransitionBlack"
	_black.color = Color.BLACK
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_black)
	_black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _layout() -> void:
	if not is_instance_valid(_skip_button):
		return
	_ui_scale = clampf(minf(size.x / 1280.0, size.y / 720.0), 0.68, 1.6)
	var margin := maxf(18.0, 30.0 * _ui_scale)
	_skip_button.custom_minimum_size = Vector2(218, 62) * _ui_scale
	_skip_button.size = _skip_button.custom_minimum_size
	_skip_button.position = Vector2(size.x - _skip_button.size.x - margin, margin)
	_skip_button.add_theme_font_size_override("font_size", roundi(24.0 * _ui_scale))
	_hint.position = _skip_button.position + Vector2(0, _skip_button.size.y + 3.0 * _ui_scale)
	_hint.size = Vector2(_skip_button.size.x, 26.0 * _ui_scale)
	_hint.add_theme_font_size_override("font_size", roundi(17.0 * _ui_scale))
	_caption.position = Vector2(size.x * 0.065, size.y * 0.775)
	_caption.size = Vector2(size.x * 0.87, size.y * 0.17)
	_caption.add_theme_font_size_override("font_size", roundi(34.0 * _ui_scale))
	_render_frame()


func _process(delta: float) -> void:
	process_elapsed(delta)


## Also allows deterministic headless checks without waiting for wall-clock time.
func process_elapsed(delta: float) -> void:
	if is_finished or not is_instance_valid(_black):
		return
	if _skipping:
		_skip_elapsed += maxf(delta, 0.0)
		_black.modulate.a = lerpf(_skip_from, 1.0, _smooth(_skip_elapsed / SKIP_FADE))
		if _skip_elapsed >= SKIP_FADE:
			_complete()
		return
	elapsed = minf(elapsed + maxf(delta, 0.0), duration_seconds)
	_render_frame()
	if elapsed >= duration_seconds:
		_complete()


## Frame preview for editor/render checks. Does not emit `finished`.
func seek(seconds: float) -> void:
	if is_finished or _skipping:
		return
	elapsed = clampf(seconds, 0.0, duration_seconds)
	if is_instance_valid(_black):
		_render_frame()


func skip() -> void:
	if is_finished or _skipping or elapsed < SKIP_GUARD:
		return
	_skipping = true
	_skip_elapsed = 0.0
	_skip_from = _black.modulate.a
	_skip_button.disabled = true


func _unhandled_input(event: InputEvent) -> void:
	# Only a fresh press after the guard can skip. The menu's opening press,
	# held-key repeats, key releases, and touching the picture do nothing.
	if elapsed < SKIP_GUARD or is_finished or _skipping or event.is_echo():
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		skip()


func _render_frame() -> void:
	if not is_instance_valid(_black) or size.x <= 0.0 or size.y <= 0.0:
		return
	var story_time := elapsed * STORY_LENGTH / maxf(duration_seconds, 0.01)
	var progress := clampf(story_time / STORY_LENGTH, 0.0, 1.0)
	var image_size := kingdom_texture.get_size() if kingdom_texture else Vector2(1672, 941)
	var cover := maxf(size.x / image_size.x, size.y / image_size.y)
	var zoom := lerpf(1.055, 1.14, _smooth(progress))
	_kingdom.size = image_size * cover * zoom
	# A small drift toward the central castle; cover scaling never distorts art.
	var overflow := _kingdom.size - size
	_kingdom.position = -overflow * Vector2(lerpf(0.49, 0.64, progress), lerpf(0.47, 0.52, progress))
	_kingdom_material.set_shader_parameter("elapsed", story_time)
	_kingdom_material.set_shader_parameter("darkness", _smooth((story_time - 2.0) / 4.1))

	var flight := clampf((story_time - 5.75) / 3.10, 0.0, 1.0)
	var visibility := _smooth((story_time - 5.75) / 0.48)
	var hero_size := lerpf(16.0, 244.0, pow(flight, 1.5)) * _ui_scale
	var hero_center := _flight_position(flight)
	_jiskra.size = Vector2.ONE * hero_size
	_jiskra.pivot_offset = _jiskra.size * 0.5
	_jiskra.position = hero_center - _jiskra.size * 0.5
	_jiskra.rotation = lerpf(-0.20, 0.055, _smooth(flight)) + sin(flight * TAU) * 0.065
	_jiskra.modulate.a = visibility
	_light.center = hero_center
	_light.radius = hero_size * 0.70
	_light.alpha = visibility
	_light.time = story_time
	_light.sparkles.clear()
	for i in range(28):
		var age := float(i + 1) / 28.0
		var trail_flight := flight - age * 0.50
		if trail_flight <= 0.0:
			continue
		var p := _flight_position(trail_flight)
		p += Vector2(sin(float(i) * 2.4 + story_time) * 14.0, cos(float(i) * 1.8 + story_time * 0.6) * 12.0) * _ui_scale
		_light.sparkles.append(Vector4(p.x, p.y, (1.0 - age) * visibility, float(i)))
	_light.unit_scale = _ui_scale
	_light.queue_redraw()

	if story_time < 5.70:
		_caption.text = "Do Království snů se vplížila temnota…"
		_caption.modulate.a = _smooth((story_time - 2.65) / 0.65) * (1.0 - _smooth((story_time - 5.0) / 0.60))
	else:
		_caption.text = "Bite… Království snů tě potřebuje."
		_caption.modulate.a = _smooth((story_time - 6.10) / 0.60)
	_skip_button.disabled = elapsed < SKIP_GUARD
	_skip_button.modulate.a = lerpf(0.65, 0.94, _smooth(elapsed / SKIP_GUARD))
	var opening_fade := 1.0 - _smooth(story_time / 0.55)
	var ending_fade := _smooth((story_time - 8.70) / 0.80)
	_black.modulate.a = maxf(opening_fade, ending_fade)


func _flight_position(flight: float) -> Vector2:
	var eased := _smooth(flight)
	var x := lerpf(0.63, 0.51, eased) + sin(flight * PI) * 0.10
	var y := lerpf(0.35, 0.46, eased) - sin(flight * PI) * 0.06
	return size * Vector2(x, y)


func _complete() -> void:
	if is_finished:
		return
	is_finished = true
	_black.modulate.a = 1.0
	_skip_button.disabled = true
	set_process(false)
	set_process_unhandled_input(false)
	# The owner may remove/free this node from the signal callback.
	finished.emit()


func _smooth(value: float) -> float:
	var t := clampf(value, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


class DreamLight extends Node2D:
	var center := Vector2.ZERO
	var radius := 100.0
	var alpha := 0.0
	var time := 0.0
	var unit_scale := 1.0
	var sparkles: Array[Vector4] = []

	func _draw() -> void:
		if alpha <= 0.0:
			return
		# Translucent nested circles produce a gentle warm bloom without a
		# screen-space glow pass; only a few dozen tiny trail marks are drawn.
		for i in range(14, 0, -1):
			var fraction := float(i) / 14.0
			draw_circle(center, radius * fraction, Color(1.0, 0.73, 0.24, alpha * 0.023 * (1.0 - fraction * 0.5)))
		for spark in sparkles:
			var point := Vector2(spark.x, spark.y)
			var twinkle := 0.70 + sin(time * 2.4 + spark.w * 1.7) * 0.22
			var opacity := spark.z * twinkle
			var r := (1.5 + fmod(spark.w, 3.0)) * unit_scale
			draw_circle(point, r * 2.7, Color(1.0, 0.72, 0.25, opacity * 0.075))
			draw_circle(point, r, Color(1.0, 0.91, 0.58, opacity * 0.80), true, -1.0, true)
			if int(spark.w) % 5 == 0:
				draw_line(point - Vector2(r * 2.0, 0), point + Vector2(r * 2.0, 0), Color(1.0, 0.97, 0.77, opacity), unit_scale, true)
				draw_line(point - Vector2(0, r * 2.5), point + Vector2(0, r * 2.5), Color(1.0, 0.97, 0.77, opacity), unit_scale, true)

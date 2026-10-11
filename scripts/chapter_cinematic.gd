extends Control
## Five in-engine shots, with an approved Higgsfield painting of the Heart.
signal finished
const FONT = preload("res://assets/ui/fonts/Nunito.ttf")
const BIT = preload("res://assets/shared/pieces/idle.png")
const JISKRA = preload("res://assets/shared/pieces/jiskra.png")
const LANTERN = preload("res://assets/environment/castle/higgsfield/RoyalLantern.tres")
const STAR = preload("res://assets/environment/worldkit/star_key.tres")
const HEART = preload("res://assets/environment/cinematics/chapter_one/heart.png")
const DURATION := 36.0
const TIMES := [0.0, 5.0, 13.0, 21.0, 30.0, 36.0]
const CAPTIONS := [
	"Jiskra je volná. Na chvíli se do věže vrací světlo…",
	"Ale z hlubin hradu stále proudí temnota do celého království.",
	"Jiskra: Morous dál vysává Srdce. Já tu zůstanu a budu ho chránit.",
	"Jiskra: Do téhle lucerny ukryj tři čisté esence — život, vzpomínky a naději.",
	"Jiskra: První cestu najdeš v Zahradách obrů. Věřím ti, Bite."
]
var elapsed := 0.0
var shot := 0
var ended := false
var paused := false
var subtitle: Label
var skip_button: Button
var pause_button: Button
var pictures: Dictionary = {}
var ink: Node2D
var readable_font: FontVariation

func _ready() -> void:
	name = "ChapterOneCinematic"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	readable_font = FontVariation.new()
	readable_font.base_font = FONT
	readable_font.variation_opentype = {0x77676874: 650}
	for stage in [1, 6, 10]:
		var strips: Array[Texture2D] = []
		for index in 4:
			strips.append(load("res://assets/environment/backgrounds/story/level_%02d/part_%d.png" % [stage, index]))
		pictures[stage] = strips
	ink = Node2D.new()
	add_child(ink)
	ink.draw.connect(_draw_scene)
	subtitle = Label.new()
	subtitle.position = Vector2(115, 603)
	subtitle.size = Vector2(1050, 80)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_override("font", readable_font)
	subtitle.add_theme_font_size_override("font_size", 25)
	subtitle.add_theme_color_override("font_color", Color("fff7df"))
	add_child(subtitle)
	skip_button = _button("Přeskočit →", Vector2(1060, 27), skip)
	pause_button = _button("Pozastavit", Vector2(25, 27), toggle_pause)
	_update_shot()

func _button(label: String, at: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.position = at
	button.size = Vector2(192, 43)
	button.add_theme_font_override("font", readable_font)
	button.add_theme_font_size_override("font_size", 19)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.21, 0.85)
	style.border_color = Color("9cbcc6")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	button.add_theme_stylebox_override("normal", style)
	button.pressed.connect(callback)
	add_child(button)
	return button

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	paused = not paused
	pause_button.text = "Pokračovat" if paused else "Pozastavit"

func _process(delta: float) -> void:
	if ended: return
	if not paused: elapsed = minf(DURATION, elapsed + delta)
	_update_shot()
	skip_button.disabled = elapsed < 0.7
	ink.queue_redraw()
	if elapsed >= DURATION: _finish()

func _update_shot() -> void:
	shot = 0
	for index in range(1, 5):
		if elapsed >= TIMES[index]: shot = index
	subtitle.text = CAPTIONS[shot]

func skip() -> void:
	if elapsed < 0.7 or ended: return
	_finish()

func _finish() -> void:
	if ended: return
	ended = true
	finished.emit()

func _background(stage: int, zoom: float, offset: Vector2, tint: Color = Color.WHITE) -> void:
	var size := Vector2(1280, 720) * zoom
	var origin := (Vector2(1280, 720) - size) * 0.5 + offset
	for index in 4:
		ink.draw_texture_rect_region(pictures[stage][index], Rect2(origin + Vector2(index * size.x / 4, 0), Vector2(size.x / 4 + 0.5, size.y)), Rect2(2, 2, 418, 941), tint)

func _picture(texture: Texture2D, feet: Vector2, height: float, tint: Color = Color.WHITE) -> void:
	var width := height * texture.get_width() / float(texture.get_height())
	ink.draw_texture_rect(texture, Rect2(feet - Vector2(width * 0.5, height), Vector2(width, height)), false, tint)

func _draw_scene() -> void:
	var t := clampf((elapsed - TIMES[shot]) / (TIMES[shot + 1] - TIMES[shot]), 0, 1)
	ink.draw_rect(Rect2(0, 0, 1280, 720), Color("0c1629"))
	match shot:
		0:
			_background(10, 1.15 - t * 0.07, Vector2(-30, 0), Color(0.72 + t * 0.28, 0.70 + t * 0.30, 0.86))
			for i in 8: ink.draw_circle(Vector2(795, 367), 110 + i * 28 + t * 50, Color(1, 0.85, 0.41, 0.024))
			_picture(BIT, Vector2(455, 581), 228)
			_picture(JISKRA, Vector2(795, 445 - sin(t * PI) * 24), 190)
			for i in 10:
				var point := Vector2(795, 350) + Vector2(cos(i * 2.4), sin(i * 2.4)) * (80 + t * 190)
				ink.draw_circle(point, 4 * (1 - t), Color("edd5fc"))
		1:
			_background(6, 1.19 - t * 0.13, Vector2(0, 24 - t * 20), Color("9695b0"))
			var source := Vector2(950, 260)
			for index in 8:
				var points := PackedVector2Array()
				for i in 40:
					var u := float(i) / 39.0
					points.append(source + Vector2(-u * 1120, index * 29 * u + sin(u * 7 + elapsed * 0.5 + index) * u * 49))
				ink.draw_polyline(points, Color(0.12, 0.05, 0.22, 0.32), 28, true)
				ink.draw_polyline(points, Color(0.53, 0.28, 0.67, 0.21), 7, true)
			for point in [Vector2(250, 510), Vector2(510, 485), Vector2(775, 430)]:
				for i in 5: ink.draw_circle(point, 9 + i * 8, Color(1, 0.86, 0.32, 0.08))
		2:
			var frame_size := Vector2(1280, 720) * (1.0 + t * 0.065)
			var frame_origin := (Vector2(1280, 720) - frame_size) * 0.5
			ink.draw_texture_rect(HEART, Rect2(frame_origin, frame_size), false, Color("c2bfd4"))
			var beat := 0.5 + sin(elapsed * 2.3) * 0.5
			for i in 8:
				ink.draw_circle(Vector2(640, 267), 45 + i * 10, Color(0.55, 1.0, 0.88, beat * 0.006))
		3:
			_background(10, 1.14, Vector2.ZERO, Color("a2a6b8"))
			_picture(BIT, Vector2(420, 581), 225)
			_picture(JISKRA, Vector2(866, 446), 180)
			var lamp := Vector2(lerpf(790, 580, smoothstep(0, 0.5, t)), 505)
			_picture(LANTERN, lamp, 165)
			for i in 5: ink.draw_circle(lamp - Vector2(0, 90), 33 + i * 14, Color(1, 0.85, 0.36, 0.05))
			var alpha := smoothstep(0.25, 0.6, t)
			# Essence symbols are intentionally distinct from collectible golden stars.
			var drop := PackedVector2Array([Vector2(488, 185), Vector2(465, 230), Vector2(465, 247), Vector2(482, 261), Vector2(497, 261), Vector2(512, 247), Vector2(512, 230)])
			ink.draw_colored_polygon(drop, Color(0.40, 0.93, 0.80, alpha))
			ink.draw_circle(Vector2(640, 230), 28, Color(0.86, 0.86, 1, alpha))
			_picture(STAR, Vector2(792, 264), 70, Color(0.74, 0.91, 1, alpha))
			for i in 3:
				var label: String = ["ŽIVOT", "VZPOMÍNKY", "NADĚJE"][i]
				ink.draw_string(FONT, Vector2(449 + i * 152, 302), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 0.94, 0.78, alpha))
		4:
			_background(1, 1.06 + t * 0.06, Vector2(0, 0), Color("a3ae8b"))
			for i in 10: ink.draw_arc(Vector2(866, 340), 146 + i * 6, 0, TAU, 80, Color(0.39, 0.9, 0.8, 0.11 - i * 0.008), 6, true)
			_picture(BIT, Vector2(lerpf(440, 690, t), 576), 220)
			_picture(LANTERN, Vector2(lerpf(502, 752, t), 529), 86)
			ink.draw_string(FONT, Vector2(428, 162), "CESTA ZA TŘEMI ESENCEMI", HORIZONTAL_ALIGNMENT_LEFT, -1, 29, Color("fff2bd"))
	# Letterbox and subtitles remain constant while shots change underneath.
	ink.draw_rect(Rect2(0, 0, 1280, 90), Color("0c1421"))
	ink.draw_rect(Rect2(0, 586, 1280, 134), Color(0.04, 0.07, 0.12, 0.96))
	var edge := minf((elapsed - TIMES[shot]) / 0.55, (TIMES[shot + 1] - elapsed) / 0.55)
	if edge < 1: ink.draw_rect(Rect2(0, 90, 1280, 496), Color(0.03, 0.04, 0.09, 1 - clampf(edge, 0, 1)))

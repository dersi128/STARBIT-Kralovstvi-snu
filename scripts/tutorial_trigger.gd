@tool
extends Marker2D
## A short contextual hint. Move this marker to edit where the hint appears.
@export var title := "Rada"
@export_multiline var message := ""
@export_multiline var touch_message := ""
@export var activation_size := Vector2(560, 360):
	set(value):
		activation_size = value
		queue_redraw()
@export_range(3.0, 12.0, 0.5) var display_seconds := 7.0

var completed := false
var card: Control

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or completed or is_instance_valid(card):return
	var game = get_tree().get_first_node_in_group("game")
	if game == null or game.mode != "play" or not is_instance_valid(game.level):return
	if not game.level.is_ancestor_of(self) or not contains_player(game.level.player):return
	# A nearby hint waits for the previous card instead of covering it.
	if game.screen.has_node("TutorialHint"):return
	var text := touch_message if DisplayServer.is_touchscreen_available() and not touch_message.is_empty() else message
	if text.strip_edges().is_empty():return
	card = TutorialCard.new()
	game.screen.add_child(card)
	card.setup(self, game, title, text)

func contains_player(player: Node2D) -> bool:
	return is_instance_valid(player) and Rect2(-activation_size * 0.5, activation_size).has_point(to_local(player.global_position))

func _draw() -> void:
	if not Engine.is_editor_hint():return
	var bounds := Rect2(-activation_size * 0.5, activation_size)
	draw_rect(bounds, Color(0.3, 0.85, 0.7, 0.08))
	draw_rect(bounds, Color(0.3, 0.85, 0.7, 0.65), false, 2.0)

class TutorialCard extends Control:
	const FONT = preload("res://assets/menu/Nunito.ttf")
	const DESIGN_SIZE = Vector2(1280, 720)
	var source: Node2D
	var game: Node
	var canvas: Control
	var elapsed := 0.0
	var fade_out := -1.0

	func setup(trigger: Node2D, controller: Node, heading: String, text: String) -> void:
		name = "TutorialHint"
		source = trigger
		game = controller
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		canvas = Control.new()
		canvas.size = DESIGN_SIZE
		canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(canvas)
		var panel := Panel.new()
		panel.position = Vector2(280, 86)
		panel.size = Vector2(720, 120)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.bg_color = Color("fff8e7")
		style.border_color = Color("fffef5")
		style.set_border_width_all(3)
		style.set_corner_radius_all(22)
		style.shadow_color = Color(0.04, 0.15, 0.25, 0.25)
		style.shadow_size = 4
		style.shadow_offset = Vector2(0, 4)
		panel.add_theme_stylebox_override("panel", style)
		canvas.add_child(panel)
		var caption := _label(heading, Rect2(304, 97, 672, 27), 18, Color("26745d"))
		caption.name = "Heading"
		var body := _label(text, Rect2(304, 128, 672, 65), 23, Color("203e57"))
		body.name = "HintText"
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		modulate.a = 0.0
		resized.connect(_fit)
		_fit()

	func _label(text: String, bounds: Rect2, font_size: int, ink: Color) -> Label:
		var label := Label.new()
		label.text = text
		label.position = bounds.position
		label.size = bounds.size
		var font := FontVariation.new()
		font.base_font = FONT
		font.variation_opentype = {0x77676874: 750}
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", font_size)
		label.add_theme_color_override("font_color", ink)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		canvas.add_child(label)
		return label

	func _fit() -> void:
		var factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
		canvas.scale = Vector2.ONE * factor
		canvas.position = (size - DESIGN_SIZE * factor) * 0.5

	func _process(delta: float) -> void:
		if not is_instance_valid(source) or not is_instance_valid(game):
			queue_free()
			return
		visible = game.mode == "play"
		if not visible:return
		elapsed += delta
		if fade_out >= 0.0:
			fade_out += delta
			modulate.a = maxf(0.0, 1.0 - fade_out / 0.25)
			if fade_out >= 0.25:
				source.completed = true
				queue_free()
			return
		modulate.a = minf(1.0, elapsed / 0.18)
		# Give even a fast-moving player time to read; never pause gameplay.
		if elapsed >= source.display_seconds or (elapsed >= 3.0 and not source.contains_player(game.level.player)):
			fade_out = 0.0

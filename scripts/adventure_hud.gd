extends Control
## One consistent, compact status strip for the new adventure levels.
const FONT = preload("res://assets/ui/fonts/Nunito.ttf")
const HEART = preload("res://assets/ui/adventure/heart.svg")
const EMPTY_HEART = preload("res://assets/ui/adventure/heart_empty.svg")
const PAUSE_ICON = preload("res://assets/ui/adventure/pause.svg")
const DIAMOND = preload("res://assets/environment/worldkit/crystal.tres")
const STAR = preload("res://assets/environment/worldkit/star_key.tres")
const GEAR = preload("res://assets/environment/forest/awakening/gear.png")
var level: Node2D
var objective: Label
var diamond_count: Label
var hearts: Array[TextureRect] = []
var diamond_icon: TextureRect
var star_icon: TextureRect
var gear_icon: TextureRect
var status_ink: Node2D
var _health := -1
var _count := -1
var _total := -1
var _has_key := false
var _gear_state := -1
var _initialized := false
var _motions: Dictionary = {}

func _ready() -> void:
	name = "AdventureHUD"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel(Rect2(22, 16, 402, 60))
	_panel(Rect2(440, 16, 726, 60))
	for i in 3:
		hearts.append(_icon(HEART, Rect2(35 + i * 34, 30, 31, 33)))
	diamond_icon = _icon(DIAMOND, Rect2(158, 24, 36, 43))
	diamond_count = _label(Rect2(200, 25, 84, 42), 24, Color("234e43"), 850)
	star_icon = _icon(STAR, Rect2(300, 25, 43, 43))
	gear_icon = _icon(GEAR, Rect2(362, 29, 34, 35))
	_label(Rect2(458, 21, 670, 16), 11, Color("718566"), 850).text = "TVŮJ ÚKOL"
	objective = _label(Rect2(458, 35, 692, 31), 18, Color("234e43"), 750)
	objective.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	status_ink = Node2D.new()
	add_child(status_ink)
	status_ink.draw.connect(_draw_status)
	_sync_quest(false)

func _panel(bounds: Rect2) -> void:
	var panel := Panel.new()
	panel.position = bounds.position
	panel.size = bounds.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.show_behind_parent = true
	panel.add_theme_stylebox_override("panel", paper_style())
	add_child(panel)

static func paper_style(fill := Color("fff7e6")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = Color("64856b")
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0.06, 0.18, 0.13, 0.25)
	style.shadow_size = 3
	style.shadow_offset = Vector2(0, 3)
	return style

static func style_pause(button: Button) -> void:
	button.text = ""
	button.icon = PAUSE_ICON
	button.custom_minimum_size = Vector2(64, 60)
	button.add_theme_color_override("font_color", Color("234e43"))
	button.add_theme_stylebox_override("normal", paper_style())
	button.add_theme_stylebox_override("hover", paper_style(Color("fffff4")))
	button.add_theme_stylebox_override("pressed", paper_style(Color("e7edda")))
	var focus := paper_style()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Color("d6a848")
	button.add_theme_stylebox_override("focus", focus)

func _icon(texture: Texture2D, bounds: Rect2) -> TextureRect:
	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.texture = texture
	icon.position = bounds.position
	icon.size = bounds.size
	icon.pivot_offset = bounds.size * 0.5
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon)
	return icon

func _label(bounds: Rect2, font_size: int, color: Color, weight: int) -> Label:
	var label := Label.new()
	label.position = bounds.position
	label.size = bounds.size
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var font := FontVariation.new()
	font.base_font = FONT
	font.variation_opentype = {0x77676874: weight}
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _process(_delta: float) -> void:
	_sync_quest(true)

func update_values(diamonds: int, has_key: bool, total: int, animate := true) -> void:
	if diamonds != _count or total != _total:
		diamond_count.text = "%d / %d" % [maxi(0, diamonds), maxi(0, total)]
		if animate and _initialized and diamonds > _count:_pulse(diamond_icon)
		_count = diamonds
		_total = total
	if not _initialized or has_key != _has_key:
		star_icon.modulate = Color.WHITE if has_key else Color(0.45, 0.53, 0.45, 0.30)
		if animate and _initialized and has_key:_pulse(star_icon)
		_has_key = has_key
	_sync_quest(animate)
	_initialized = true

func _sync_quest(animate: bool) -> void:
	if not is_instance_valid(level) or not is_instance_valid(level.player):return
	if level.bonus_active and level.has_node("BonusRoom"):
		objective.text = level.get_node("BonusRoom").objective_text()
	elif level.has_method("objective_text"):objective.text = level.objective_text()
	var health: int = clampi(level.player.health, 0, 3)
	if health != _health:
		for i in 3:
			hearts[i].texture = HEART if i < health else EMPTY_HEART
			if animate and _health >= 0 and ((i >= health and i < _health) or (i < health and i >= _health)):_pulse(hearts[i])
		_health = health
	var state := 2 if level.completed_actions.get("winch_repaired", false) else (1 if level.inventory.get("bridge_gear", 0) > 0 else 0)
	if state != _gear_state:
		gear_icon.modulate = Color.WHITE if state == 1 else Color(0.50, 0.57, 0.47, 0.25)
		if animate and state == 1:_pulse(gear_icon)
		_gear_state = state
		status_ink.queue_redraw()

func _pulse(icon: TextureRect) -> void:
	var previous: Tween = _motions.get(icon)
	if previous and previous.is_valid():previous.kill()
	icon.scale = Vector2.ONE
	var motion := create_tween()
	_motions[icon] = motion
	motion.tween_property(icon, "scale", Vector2(1.15, 1.15), 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	motion.tween_property(icon, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw_status() -> void:
	for x in [145, 288, 351]:
		status_ink.draw_line(Vector2(x, 30), Vector2(x, 62), Color("d6dec5"), 1.0, true)
	if _gear_state == 2:
		status_ink.draw_circle(Vector2(398, 60), 9, Color("39866b"))
		status_ink.draw_polyline(PackedVector2Array([Vector2(394, 60), Vector2(397, 63), Vector2(402, 57)]), Color("fff7e6"), 2.0, true)

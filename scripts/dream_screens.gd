extends Control
## Selection and results share the actual menu artwork, typefaces and button skins.

const BUTTON_THEME = preload("res://scripts/pause_menu_theme.gd")
const ARTWORK = preload("res://assets/menu/starbit_illustrated_menu.png")
const FONT = preload("res://assets/menu/Nunito.ttf")
const TITLE_FONT = preload("res://assets/menu/Fredoka.ttf")
const GOLD_STAR = preload("res://assets/menu/ratings/star_gold.svg")
const EMPTY_STAR = preload("res://assets/menu/ratings/star_empty.svg")
const LOCK = preload("res://assets/menu/ratings/lock.svg")
const DIAMOND = preload("res://assets/worldkit/crystal.tres")
const DESIGN_SIZE = Vector2(1280, 720)
const BACKGROUNDS = ["forest", "forest", "village", "village", "guardian", "distant_castle", "distant_castle", "near_castle", "near_castle", "castle_court"]
const REGIONS = ["Kouzelný les a vesnička", "Cesta do Království snů"]

var canvas: Control
var busy := false
var actions: Dictionary
var body_font: FontVariation
var heading_font: FontVariation

func _base() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	body_font = FontVariation.new()
	body_font.base_font = FONT
	body_font.variation_opentype = {0x77676874: 850.0}
	heading_font = FontVariation.new()
	heading_font.base_font = TITLE_FONT
	heading_font.variation_opentype = {0x77676874: 650.0}
	var surround := ColorRect.new()
	surround.color = Color("88caff")
	surround.mouse_filter = Control.MOUSE_FILTER_IGNORE
	surround.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(surround)
	canvas = Control.new()
	canvas.name = "DreamCanvas"
	canvas.size = DESIGN_SIZE
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	_picture(canvas, ARTWORK, Rect2(Vector2.ZERO, DESIGN_SIZE), true)
	# Opaque boards below cover the buttons baked into the source menu image.
	_total_badge()
	resized.connect(_fit)
	_fit()

func _fit() -> void:
	if canvas == null:return
	var factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size - DESIGN_SIZE * factor) * 0.5

func show_selection(titles: Array, page: int, selected: int, callbacks: Dictionary) -> void:
	name = "LevelSelection"
	actions = callbacks
	_base()
	_panel(canvas, Rect2(72, 230, 1136, 474), Color("eaf7ff"))
	_text(canvas, "Výběr levelů", Rect2(310, 240, 660, 48), 38, true)
	_text(canvas, REGIONS[page], Rect2(300, 285, 680, 30), 22)
	var previous := _button("‹", "blue", Rect2(100, 249, 90, 60), func(): _act("page", -1), true)
	previous.disabled = page == 0
	if previous.disabled:previous.modulate = Color(0.68, 0.78, 0.85)
	var next := _button("›", "blue", Rect2(1090, 249, 90, 60), func(): _act("page", 1), true)
	next.disabled = (page + 1) * 5 >= titles.size()
	if next.disabled:next.modulate = Color(0.68, 0.78, 0.85)
	for i in 5:
		var n := page * 5 + i + 1
		if n > titles.size():break
		var card := LevelCard.new()
		card.name = "LevelCard%d" % n
		card.position = Vector2(100 + i * 220, 328)
		card.size = Vector2(200, 242)
		card.level_number = n
		card.activate = func(number: int): _act("select", number)
		card.disabled = n > Progress.unlocked
		card.tooltip_text = titles[n - 1] + (" · Zamčeno" if card.disabled else "")
		card.prepare(n == selected)
		canvas.add_child(card)
		var art: Texture2D = load("res://assets/environments/" + BACKGROUNDS[n - 1] + ".png")
		var thumbnail := _picture(card, art, Rect2(12, 12, 176, 111), true)
		if card.disabled:thumbnail.modulate = Color(0.52, 0.62, 0.72)
		_panel(card, Rect2(20, 20, 36, 36), Color("296497"), 14)
		var number := _text(card, str(n), Rect2(20, 19, 36, 36), 23, true)
		number.add_theme_color_override("font_color", Color.WHITE)
		_text(card, titles[n - 1], Rect2(14, 134, 172, 51), 18)
		_star_row(card, Progress.best_stars(n), Vector2(45, 196), 34)
		if card.disabled:_picture(card, LOCK, Rect2(76, 40, 48, 56))
	_button("Zpět", "purple", Rect2(337, 612, 284, 76), func(): _act("back"))
	var play := _button("Hrát level %d" % selected, "yellow", Rect2(659, 612, 284, 76), func(): _act("play"))
	play.disabled = selected > Progress.unlocked
	if play.disabled:play.modulate = Color(0.72, 0.78, 0.83)

func show_result(number: int, title: String, diamonds: int, total: int, result: Dictionary, callbacks: Dictionary) -> void:
	name = "LevelResult"
	actions = callbacks
	_base()
	_panel(canvas, Rect2(366, 230, 548, 400), Color("fff8e3"))
	_text(canvas, "Level dokončen!", Rect2(392, 242, 496, 44), 36, true)
	_text(canvas, "%d · %s" % [number, title], Rect2(390, 289, 500, 34), 22)
	var earned: int = result.get("earned", 1)
	var stars := _star_row(canvas, 0, Vector2(488, 334), 88, 20)
	for i in 3:
		var caption: String = ["Dokončeno", "Více než půlka", "Všechny"][i]
		_text(canvas, caption, Rect2(466 + i * 108, 426, 132, 25), 15)
		if i < earned:
			var star := stars[i]
			var animation := create_tween()
			animation.tween_interval(0.14 + i * 0.18)
			animation.tween_callback(func(): star.texture = GOLD_STAR; star.scale = Vector2.ONE * 0.6)
			animation.tween_property(star, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_picture(canvas, DIAMOND, Rect2(499, 464, 36, 42))
	_text(canvas, "%d / %d diamantů" % [diamonds, total], Rect2(541, 465, 242, 40), 27)
	_text(canvas, "Nejlepší: %d / 3   ·   Nové hvězdy: +%d" % [result.get("best", 0), result.get("added", 0)], Rect2(400, 510, 480, 28), 18)
	var last := number >= Progress.LEVEL_COUNT
	_button("Výběr levelů" if last else "Další level", "yellow", Rect2(432, 546, 416, 70), func(): _act("selection" if last else "next"))
	# The footer board also covers the artwork's original small credit caption.
	_panel(canvas, Rect2(324, 636, 632, 78), Color("eaf7ff"), 28)
	_button("Hrát znovu", "blue", Rect2(338, 640, 284, 70), func(): _act("replay"))
	_button("Hlavní menu" if last else "Výběr levelů", "purple", Rect2(658, 640, 284, 70), func(): _act("menu" if last else "selection"))

func _act(key: String, value: int = 0) -> void:
	if busy:return
	busy = true
	if key in ["page", "select"]:actions[key].call(value)
	else:actions[key].call()

func _total_badge() -> void:
	var panel := _panel(canvas, Rect2(1036, 25, 220, 82), Color("fff1b2"), 28)
	panel.name = "TotalStars"
	_picture(panel, GOLD_STAR, Rect2(12, 17, 48, 48))
	_text(panel, "Hvězdy celkem", Rect2(65, 10, 143, 24), 17)
	var count := _text(panel, str(Progress.total_stars()), Rect2(65, 31, 143, 40), 34, true)
	count.name = "TotalCount"

func _text(parent: Node, caption: String, bounds: Rect2, font_size: int, heading := false) -> Label:
	var label := Label.new()
	label.text = caption
	label.position = bounds.position
	label.size = bounds.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", heading_font if heading else body_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("143d65"))
	parent.add_child(label)
	return label

func _picture(parent: Node, texture: Texture2D, bounds: Rect2, cover := false) -> TextureRect:
	var picture := TextureRect.new()
	picture.texture = texture
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.position = bounds.position
	picture.size = bounds.size
	picture.pivot_offset = bounds.size * 0.5
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(picture)
	return picture

func _panel(parent: Node, bounds: Rect2, fill: Color, radius := 32) -> Panel:
	var panel := Panel.new()
	panel.position = bounds.position
	panel.size = bounds.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = Color("faffff")
	style.set_border_width_all(3)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.04, 0.18, 0.34, 0.3)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 5)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

func _star_row(parent: Node, earned: int, at: Vector2, side: float, gap := 4.0) -> Array[TextureRect]:
	var icons: Array[TextureRect] = []
	for i in 3:
		var star := _picture(parent, GOLD_STAR if i < earned else EMPTY_STAR, Rect2(at + Vector2(i * (side + gap), 0), Vector2.ONE * side))
		star.name = "RatingStar%d" % (i + 1)
		icons.append(star)
	return icons

func _button(caption: String, palette: String, bounds: Rect2, action: Callable, compact := false) -> Button:
	var button := BUTTON_THEME.button(caption, action, palette)
	button.custom_minimum_size = bounds.size
	button.position = bounds.position
	button.size = bounds.size
	if not compact and bounds.size.x <= 300:
		button.add_theme_font_size_override("font_size", 26)
	if compact:
		button.add_theme_font_size_override("font_size", 38)
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			var style := button.get_theme_stylebox(state).duplicate() as StyleBoxTexture
			style.content_margin_left = 12
			style.content_margin_right = 12
			button.add_theme_stylebox_override(state, style)
	canvas.add_child(button)
	if compact:
		for star in button.accents:star.hide()
	return button

class LevelCard extends Button:
	var level_number := 1
	var activate: Callable
	var motion: Tween
	var locked := false

	func prepare(selected: bool) -> void:
		mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
		focus_mode = Control.FOCUS_NONE if disabled else Control.FOCUS_ALL
		var base := StyleBoxFlat.new()
		base.bg_color = Color("ffde78") if selected else Color("bcecff")
		base.border_color = Color("fff9d6") if selected else Color("ffffff")
		base.set_border_width_all(3)
		base.set_corner_radius_all(25)
		base.shadow_color = Color(0.05, 0.20, 0.35, 0.28)
		base.shadow_size = 4
		base.shadow_offset = Vector2(0, 6)
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			var style := base.duplicate() as StyleBoxFlat
			if state == "hover":style.bg_color = style.bg_color.lightened(0.13)
			if state in ["pressed", "hover_pressed"]:style.bg_color = style.bg_color.darkened(0.08)
			if state == "disabled":style.bg_color = Color("d0e2eb")
			add_theme_stylebox_override(state, style)
		var focus := base.duplicate() as StyleBoxFlat
		focus.draw_center = false
		focus.border_color = Color("2557a0")
		focus.set_border_width_all(4)
		focus.shadow_size = 0
		add_theme_stylebox_override("focus", focus)
		pivot_offset = size * 0.5
		button_down.connect(func(): _scale_to(0.97))
		button_up.connect(func(): _scale_to(1.0))
		pressed.connect(_activate)

	func _has_point(point: Vector2) -> bool:
		return Rect2(Vector2.ZERO, size).has_point(pivot_offset + (point - pivot_offset) * scale)

	func _scale_to(value: float) -> void:
		if locked or disabled:return
		if motion:motion.kill()
		motion = create_tween()
		motion.tween_property(self, "scale", Vector2.ONE * value, 0.10)

	func _activate() -> void:
		if locked or disabled:return
		locked = true
		Progress.sfx("ui")
		if motion:motion.kill()
		motion = create_tween()
		motion.tween_property(self, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		motion.tween_callback(func(): activate.call(level_number))

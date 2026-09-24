extends HBoxContainer
## Compact in-game counters, using the same collectibles that appear in the level.

const DIAMOND = preload("res://assets/worldkit/crystal.tres")
const STAR_KEY = preload("res://assets/worldkit/star_key.tres")
const FONT = preload("res://assets/menu/Nunito.ttf")

var diamond_count: Label
var diamond_icon: TextureRect
var key_icon: TextureRect
var key_card: GlossyCard
var _count := -1
var _total := -1
var _has_key := false
var _initialized := false
var _diamond_motion: Tween
var _key_motion: Tween

func _ready() -> void:
	name = "CollectibleHUD"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 12)
	var diamond_card := GlossyCard.new()
	diamond_card.name = "Diamonds"
	diamond_card.custom_minimum_size = Vector2(206, 64)
	diamond_card.set_palette(Color("78d8f5"), Color("e7fcff"), 12)
	add_child(diamond_card)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	diamond_card.add_child(row)
	diamond_icon = _icon(DIAMOND, Vector2(44, 50))
	row.add_child(diamond_icon)
	diamond_count = Label.new()
	diamond_count.name = "Count"
	diamond_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	diamond_count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	diamond_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	diamond_count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var typeface := FontVariation.new()
	typeface.base_font = FONT
	typeface.variation_opentype = {0x77676874: 950.0}
	diamond_count.add_theme_font_override("font", typeface)
	diamond_count.add_theme_font_size_override("font_size", 30)
	diamond_count.add_theme_color_override("font_color", Color("103d69"))
	diamond_count.add_theme_color_override("font_shadow_color", Color(1, 1, 1, 0.6))
	diamond_count.add_theme_constant_override("shadow_offset_x", 0)
	diamond_count.add_theme_constant_override("shadow_offset_y", 1)
	row.add_child(diamond_count)
	key_card = GlossyCard.new()
	key_card.name = "StarKey"
	key_card.custom_minimum_size = Vector2(68, 64)
	add_child(key_card)
	key_icon = _icon(STAR_KEY, Vector2(54, 50))
	key_card.add_child(key_icon)
	update_values(0, false, 0, false)

func _icon(texture: Texture2D, minimum: Vector2) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = minimum
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.resized.connect(func(): icon.pivot_offset = icon.size * 0.5)
	return icon

func update_values(diamonds: int, has_key: bool, total: int, animate := true) -> void:
	# Called by the game loop, but only update visuals when a value changes.
	diamonds = maxi(diamonds, 0)
	total = maxi(total, 0)
	if diamonds != _count or total != _total:
		diamond_count.text = "%d / %d" % [diamonds, total]
		if animate and _initialized and diamonds > _count:
			_diamond_motion = _pulse(diamond_icon, _diamond_motion)
		_count = diamonds
		_total = total
	if not _initialized or has_key != _has_key:
		key_card.set_palette(Color("ffdc72") if has_key else Color("afc5d3"), Color("fff5c7") if has_key else Color("deedf5"), 7)
		key_icon.modulate = Color.WHITE if has_key else Color(0.52, 0.65, 0.78, 0.38)
		if animate and _initialized and has_key:
			_key_motion = _pulse(key_icon, _key_motion)
		_has_key = has_key
	_initialized = true

func _pulse(icon: Control, previous: Tween) -> Tween:
	if previous and previous.is_valid():
		previous.kill()
	icon.scale = Vector2.ONE
	var motion := create_tween()
	motion.tween_property(icon, "scale", Vector2(1.16, 1.16), 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	motion.tween_property(icon, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return motion

class GlossyCard extends PanelContainer:
	var shine: StyleBoxFlat

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		shine = StyleBoxFlat.new()
		shine.bg_color = Color(1, 1, 1, 0.27)
		shine.set_corner_radius_all(20)

	func set_palette(fill: Color, rim: Color, horizontal_margin: int) -> void:
		var style := StyleBoxFlat.new()
		style.bg_color = fill
		style.border_color = rim
		style.set_border_width_all(2)
		style.set_corner_radius_all(28)
		style.shadow_color = Color(0.04, 0.17, 0.3, 0.30)
		style.shadow_size = 4
		style.shadow_offset = Vector2(0, 4)
		style.content_margin_left = horizontal_margin
		style.content_margin_right = horizontal_margin
		style.content_margin_top = 7
		style.content_margin_bottom = 7
		add_theme_stylebox_override("panel", style)
		queue_redraw()

	func _draw() -> void:
		draw_style_box(shine, Rect2(5, 4, maxf(0.0, size.x - 10.0), 25))

@tool
extends "res://scripts/castle_platform.gd"
## Continuous illustrated grass. Collision still belongs to the platform base.
const MIRROR = preload("res://shaders/forest_mirror_repeat.gdshader")

func _ready() -> void:
	super._ready()
	var seamless := ShaderMaterial.new()
	seamless.shader = MIRROR
	material = seamless
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func _draw_surface() -> void:
	var source := surface_texture.get_size()
	if source.x <= 0 or source.y <= 0:return
	var ratio := surface_height / source.y
	var span := source.x * ratio
	var top := -surface_walk_y * ratio
	var left_u := position.x / span
	var right_u := (position.x + width) / span
	# One quad: no stretched end pieces, overlapping strips or horizontal fade.
	draw_polygon(PackedVector2Array([
		Vector2(0, top), Vector2(width, top),
		Vector2(width, top + surface_height), Vector2(0, top + surface_height)]),
		PackedColorArray([Color.WHITE]), PackedVector2Array([
		Vector2(left_u, 0), Vector2(right_u, 0),
		Vector2(right_u, 1), Vector2(left_u, 1)]), surface_texture)

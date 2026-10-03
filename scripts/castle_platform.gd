@tool
extends "res://scripts/platform.gd"
## Castle masonry keeps the original stone detail size, even on wide walls.
const STONE = preload("res://assets/world_expansion/platforms_starbit_v2.png")
const WALL = preload("res://assets/royal/castle_wall.png")
@export var wall_body := false:
	set(value):wall_body=value;queue_redraw()
## Optional painted shelf. Its walk row stays at collision y=0; wide shelves repeat.
@export var surface_texture: Texture2D:
	set(value):surface_texture=value;queue_redraw()
@export var surface_walk_y := 0.0:
	set(value):surface_walk_y=value;queue_redraw()
@export_range(32, 150, 1) var surface_height := 96.0:
	set(value):surface_height=value;queue_redraw()
## Horizontal repeat boundaries within the atlas region, normalized to 0..1.
@export var surface_repeat := Vector2(0.18, 0.82):
	set(value):surface_repeat=value;queue_redraw()

func _draw() -> void:
	if wall_body and depth > 95:
		# Ordinary masonry beneath the grassy shelf; keep every block at a fixed scale.
		var tile_width := 360.0
		var tile_height := tile_width * 914.0 / 1254.0
		var rows := ceili((depth - 70.0) / tile_height)
		var columns := maxi(1, ceili(width / tile_width))
		for row in rows:
			for col in columns:
				var w := minf(tile_width, width - col * tile_width)
				var h := minf(tile_height, depth - 70.0 - row * tile_height)
				draw_texture_rect_region(WALL, Rect2(col * tile_width, 55 + row * tile_height, w + 0.5, h + 0.5), Rect2(0, 0, 1254 * w / tile_width, 914 * h / tile_height), Color(0.90, 0.91, 0.97))
	if surface_texture != null:
		_draw_surface()
		if Engine.is_editor_hint() and travel.length() > 0:
			draw_line(Vector2(width / 2, 0), Vector2(width / 2, 0) + travel, Color.CYAN, 2)
		return
	var cap := minf(64, width / 3.0)
	var inside := width - cap * 2
	# Fixed-height stone shelf: only the interior repeats, the caps keep their proportions.
	draw_texture_rect_region(STONE, Rect2(-5, -25, cap + 5, 96), Rect2(20, 704, 74, 166))
	var pieces := maxi(1, ceili(inside / 140.0))
	for i in pieces:
		var segment := inside / pieces
		draw_texture_rect_region(STONE, Rect2(cap + segment * i, -25, segment + 0.6, 96), Rect2(94, 704, 178, 166))
	draw_texture_rect_region(STONE, Rect2(width - cap, -25, cap + 5, 96), Rect2(272, 704, 74, 166))
	if Engine.is_editor_hint() and travel.length() > 0:
		draw_line(Vector2(width / 2, 0), Vector2(width / 2, 0) + travel, Color.CYAN, 2)

func _draw_surface() -> void:
	var source := surface_texture.get_size()
	if source.x <= 0 or source.y <= 0: return
	var ratio := minf(surface_height / source.y, width / source.x)
	var left_pixels := source.x * clampf(surface_repeat.x, 0.01, 0.48)
	var right_start := source.x * clampf(surface_repeat.y, 0.52, 0.99)
	var right_pixels := source.x - right_start
	var left_cap := left_pixels * ratio
	var right_cap := right_pixels * ratio
	var height := source.y * ratio
	var top := -clampf(surface_walk_y, 0, source.y) * ratio
	# Caps retain their aspect ratio. Only the inner stone/plank strip repeats.
	draw_texture_rect_region(surface_texture, Rect2(0, top, left_cap, height), Rect2(0, 0, left_pixels, source.y))
	var inner_pixels := right_start - left_pixels
	var remaining := width - left_cap - right_cap
	var natural_span := inner_pixels * ratio
	var pieces := maxi(1, ceili(remaining / maxf(1, natural_span)))
	for i in pieces:
		var span := remaining / pieces
		draw_texture_rect_region(surface_texture, Rect2(left_cap + span * i, top, span + 0.35, height), Rect2(left_pixels, 0, inner_pixels, source.y))
	draw_texture_rect_region(surface_texture, Rect2(width - right_cap, top, right_cap, height), Rect2(right_start, 0, right_pixels, source.y))

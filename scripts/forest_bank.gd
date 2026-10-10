@tool
extends "res://scripts/terrain_body.gd"
## Forest-only dressing. The platform remains responsible for all collisions.
## Start inside the painted grass lip, so no strip of sky separates it from earth.
@export_range(0.0, 60.0, 1.0) var surface_overlap := 14.0:
	set(value): surface_overlap = value; queue_redraw()
@export_range(100.0, 1200.0, 1.0) var texture_span := 560.0:
	set(value): texture_span = value; queue_redraw()
@export var cool_stone := false:
	set(value): cool_stone = value; queue_redraw()

const EARTH := preload("res://assets/forest/higgsfield/forest_soil.png")

func _ready() -> void:
	super._ready()
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

func _edge(y: float, right: bool) -> float:
	# Stay within four pixels of the real wall; never imply a walkable shelf.
	var inset := 2.0 + sin(y * 0.033 + (1.7 if right else 0.0)) * 1.6
	if y < 44.0: inset += (44.0 - y) * 0.34
	return width - inset if right else inset

func _shade(y: float) -> Color:
	var near := Color(0.98, 0.98, 0.90) if not cool_stone else Color(0.74, 0.82, 0.80)
	var deep := Color(0.64, 0.76, 0.68) if not cool_stone else Color(0.54, 0.66, 0.67)
	return near.lerp(deep, clampf((y - 35.0) / 520.0, 0.0, 1.0))

func _draw() -> void:
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	var end := maxf(surface_overlap, bottom - position.y)
	var y := surface_overlap
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	while y < end:
		var next := minf(end, y + 48.0)
		var points := PackedVector2Array([
			Vector2(_edge(y, false), y), Vector2(_edge(y, true), y),
			Vector2(_edge(next, true), next), Vector2(_edge(next, false), next)])
		var uv := PackedVector2Array()
		for point in points:
			uv.append((point + position) / texture_span)
		draw_polygon(points, PackedColorArray([_shade(y), _shade(y), _shade(next), _shade(next)]), uv, EARTH)
		left.append(points[0]); right.append(points[1])
		if next == end:
			left.append(points[3]); right.append(points[2])
		y = next
	if left.size() > 1:
		draw_polyline(left, Color(0.16, 0.22, 0.17, 0.72), 2.0, true)
		draw_polyline(right, Color(0.16, 0.22, 0.17, 0.72), 2.0, true)

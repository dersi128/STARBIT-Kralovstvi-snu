@tool
extends Node2D
## Visual connections only. Anchor coordinates belong to the level, not the platform.
## A child of a moving platform therefore keeps its roots/rope fixed to the world.
@export_enum("Branch", "Stem", "Ropes") var connection := 0:
	set(value): connection = value; queue_redraw()
@export var anchor := Vector2.ZERO:
	set(value): anchor = value; queue_redraw()
@export var second_anchor := Vector2.ZERO:
	set(value): second_anchor = value; queue_redraw()
@export var bend := 38.0:
	set(value): bend = value; queue_redraw()
@export_range(6.0, 40.0, 1.0) var thickness := 24.0:
	set(value): thickness = value; queue_redraw()
@export var attach_y := 8.0:
	set(value): attach_y = value; queue_redraw()

const ART := preload("res://assets/environment/forest/higgsfield/forest_platforms.png")
const BRIDGE := preload("res://assets/environment/worldkit/starbit_bridge_parts.png")
const BARK := Rect2(1240, 346, 430, 74)
const ROPE := Rect2(146, 963, 78, 55)
var _last_parent_position := Vector2.INF

func _ready() -> void:
	z_index = -2

func _process(_delta: float) -> void:
	var host := get_parent() as Node2D
	if host != null and host.position != _last_parent_position:
		_last_parent_position = host.position
		queue_redraw()

func _curve(start: Vector2, finish: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	var rise := minf(absf(finish.x - start.x) * 0.18, 65.0) if connection == 0 else 0.0
	var control := start.lerp(finish, 0.48) + Vector2(bend, -rise)
	for i in range(17):
		var t := i / 16.0
		points.append(start * (1.0 - t) * (1.0 - t) + control * 2.0 * t * (1.0 - t) + finish * t * t)
	return points

func _plant(start: Vector2, finish: Vector2) -> void:
	var curve := _curve(start, finish)
	var edges_a := PackedVector2Array()
	var edges_b := PackedVector2Array()
	for i in curve.size():
		var tangent := curve[mini(i + 1, curve.size() - 1)] - curve[maxi(0, i - 1)]
		var normal := tangent.normalized().orthogonal()
		var radius := lerpf(thickness * 0.5, 4.5, i / 16.0) * (1.0 + sin(i * 0.7) * 0.07)
		edges_a.append(curve[i] + normal * radius)
		edges_b.append(curve[i] - normal * radius)
	var outline := PackedVector2Array(edges_a)
	for i in range(edges_b.size() - 1, -1, -1): outline.append(edges_b[i])
	outline.append(outline[0])
	draw_polyline(outline, Color(0.14, 0.23, 0.16), 2.4, true)
	for i in range(16):
		var polygon := PackedVector2Array([edges_a[i], edges_a[i+1], edges_b[i+1], edges_b[i]])
		if connection == 1:
			draw_polygon(polygon, PackedColorArray([Color(0.40, 0.59, 0.16), Color(0.40, 0.59, 0.16), Color(0.19, 0.35, 0.13), Color(0.19, 0.35, 0.13)]))
		else:
			var x1 := BARK.position.x + BARK.size.x * i / 16.0
			var x2 := BARK.position.x + BARK.size.x * (i + 1) / 16.0
			var uv := PackedVector2Array([Vector2(x1, BARK.position.y), Vector2(x2, BARK.position.y), Vector2(x2, BARK.end.y), Vector2(x1, BARK.end.y)])
			for j in uv.size(): uv[j] /= ART.get_size()
			draw_polygon(polygon, PackedColorArray([Color(0.86, 0.88, 0.77)]), uv, ART)

func _rope(start: Vector2, finish: Vector2) -> void:
	var delta := finish - start
	var count := maxi(1, ceili(delta.length() / 11.0))
	var step := delta.length() / count
	draw_set_transform(start, delta.angle())
	for i in count:
		draw_texture_rect_region(BRIDGE, Rect2(i * step, -2.9, step + 0.3, 5.8), ROPE, Color(0.86, 0.90, 0.78))
	draw_set_transform(Vector2.ZERO)

func _draw() -> void:
	var host := get_parent() as Node2D
	if host == null or not "width" in host: return
	var w: float = host.width
	var base := anchor - host.position
	if connection == 2:
		_rope(base, Vector2(22, 14))
		_rope(second_anchor - host.position, Vector2(w - 22, 14))
	else:
		_plant(base, Vector2(w * 0.5, attach_y))

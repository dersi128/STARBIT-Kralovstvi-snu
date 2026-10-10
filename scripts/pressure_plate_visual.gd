@tool
extends Node2D
## One registered stone base for both states: only its inset star lights up.
const SHEET = preload("res://assets/environment/expansion/switches.png")
const BASE_REGION := Rect2(67, 672, 314, 170)
const STAR_ANCHOR := Vector2(156, 55)

var width := 100.0:
	set(value):
		if is_equal_approx(width, value):return
		width = value
		queue_redraw()
var active := false:
	set(value):
		if active == value:return
		active = value
		queue_redraw()
var requires_crate := false:
	set(value):
		if requires_crate == value:return
		requires_crate = value
		queue_redraw()

func _ready() -> void:
	# The mirror/beam stays behind Bit, but grass cannot cover its control.
	z_as_relative = false
	z_index = 1

func _draw() -> void:
	var ratio := maxf(width, 1.0) / BASE_REGION.size.x
	# The inset star sits on the existing activation point in both states.
	draw_texture_rect_region(SHEET, Rect2(-STAR_ANCHOR * ratio, BASE_REGION.size * ratio), BASE_REGION)
	if not active and not requires_crate:return
	if active:
		# A steady, low glow stays inside the plate; no bobbing or tall particles.
		draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.62))
		draw_circle(Vector2.ZERO, width * 0.26, Color(1, 0.86, 0.33, 0.22))
		draw_set_transform(Vector2.ZERO)
	var points := PackedVector2Array()
	for i in 10:
		var angle := -PI * 0.5 + float(i) * PI / 5.0
		var radius := (42.0 if i % 2 == 0 else 22.0) * ratio
		points.append(Vector2(cos(angle), sin(angle) * 0.72) * radius)
	draw_colored_polygon(points, Color("fff4ab") if active else Color("c95f32"))

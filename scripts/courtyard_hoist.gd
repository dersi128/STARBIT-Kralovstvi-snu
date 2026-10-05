@tool
extends "res://scripts/castle_lift.gd"
## Painted courtyard lift. Movement, rider detection and return timing come from castle_lift.
## Intended for vertical travel: the fixed gantry rests on the lower landing.
@export var head_texture: Texture2D:
	set(value): head_texture = value; queue_redraw()
## Move the feet of the gantry to a floor below the lower stop, if needed.
@export_range(0, 600, 1, "suffix:px") var support_floor_offset := 0.0:
	set(value): support_floor_offset = value; queue_redraw()
@export var show_editor_path := false:
	set(value): show_editor_path = value; queue_redraw()

const WOOD_DARK := Color("553b3c")
const WOOD_EDGE := Color("8a5a3c")
const WOOD_FACE := Color("b9804b")
const WOOD_LIGHT := Color("e0b26d")
const METAL_DARK := Color("79512e")
const METAL_GOLD := Color("d8a443")
const ROPE_DARK := Color("746044")
const ROPE_LIGHT := Color("e4c993")

func _ready() -> void:
	super._ready()
	z_index = -4

func _draw() -> void:
	# The body moves; the gantry remains at the origin. The editor shows the start stop.
	var displacement := Vector2.ZERO if Engine.is_editor_hint() else position - origin
	var upper_y := minf(0.0, travel.y)
	var lower_y := maxf(0.0, travel.y) + support_floor_offset
	var beam_y := upper_y - 112.0
	var pulley_y := upper_y - 65.0
	var left_x := -15.0
	var right_x := width + 15.0
	var cord_left := 22.0
	var cord_right := width - 22.0
	var pulley_left := Vector2(cord_left, pulley_y)
	var pulley_right := Vector2(cord_right, pulley_y)
	var pulley_radius := 13.0
	var painted_head := Rect2()
	var has_painted_head := false
	if head_texture != null:
		var image_size := head_texture.get_size()
		if image_size.x > 0.0 and image_size.y > 0.0:
			var image_scale := minf((width + 76.0) / image_size.x, 92.0 / image_size.y)
			var painted_size := image_size * image_scale
			painted_head = Rect2(Vector2((width - painted_size.x) * 0.5, beam_y - 35.0), painted_size)
			# The painted header has two wheels. Animate their hubs, never a second pair.
			pulley_left = painted_head.position + painted_head.size * Vector2(64.0 / 430.0, 132.0 / 190.0)
			pulley_right = painted_head.position + painted_head.size * Vector2(364.0 / 430.0, 132.0 / 190.0)
			pulley_radius = maxf(4.0, painted_head.size.x * 22.0 / 430.0)
			has_painted_head = true
	draw_set_transform(-displacement)
	_draw_post(left_x, beam_y + 20.0, lower_y)
	_draw_post(right_x, beam_y + 20.0, lower_y)
	# Short braces support the beam without crossing the rider's path.
	_draw_timber(Vector2(left_x, beam_y + 75.0), Vector2(30, beam_y + 24.0), 12.0)
	_draw_timber(Vector2(right_x, beam_y + 75.0), Vector2(width - 30, beam_y + 24.0), 12.0)
	_draw_timber(Vector2(left_x - 14.0, beam_y + 14.0), Vector2(right_x + 14.0, beam_y + 14.0), 24.0)
	# Thin doubled cords remain connected to the moving deck at either stop.
	for side in 2:
		var pulley_center := pulley_left if side == 0 else pulley_right
		var rope_start := pulley_center + Vector2(0, pulley_radius * 0.65)
		var rope_end := displacement + Vector2(cord_left if side == 0 else cord_right, 8.0)
		draw_line(rope_start, rope_end, ROPE_DARK, 4.5, true)
		draw_line(rope_start + Vector2(-0.7, 0), rope_end + Vector2(-0.7, 0), ROPE_LIGHT, 1.8, true)
	if has_painted_head:
		draw_texture_rect(head_texture, painted_head, false)
	_draw_pulley(pulley_left, displacement.y / pulley_radius, pulley_radius, has_painted_head)
	_draw_pulley(pulley_right, -displacement.y / pulley_radius, pulley_radius, has_painted_head)
	# The lamp is a readable indication of power, with no UI text floating over the lift.
	var lamp := Vector2(width * 0.5, beam_y + 24.0)
	draw_circle(lamp, 10.0, METAL_DARK)
	draw_circle(lamp, 7.0, Color("ffdc78") if powered else Color("666b77"))
	if powered:
		draw_circle(lamp, 16.0, Color(1.0, 0.8, 0.34, 0.12))
		draw_circle(lamp + Vector2(-2, -2), 2.5, Color("fff4ca"))
	draw_set_transform(Vector2.ZERO)
	# Use the inherited cap-and-repeat renderer, so the wood art and collision stay aligned.
	if surface_texture != null:
		_draw_surface()
	else:
		_draw_timber(Vector2(0, 14), Vector2(width, 14), 28.0)
	for x in [cord_left, cord_right]:
		draw_circle(Vector2(x, 8), 5.0, METAL_DARK)
		draw_circle(Vector2(x, 8), 2.2, METAL_GOLD)
	if powered:
		draw_line(Vector2(30, 5), Vector2(width - 30, 5), Color(1.0, 0.85, 0.42, 0.65), 2, true)
	if Engine.is_editor_hint() and show_editor_path and travel.length_squared() > 0.0:
		draw_line(Vector2(width * 0.5, 0), Vector2(width * 0.5, 0) + travel, Color(0.4, 0.9, 1.0, 0.55), 2, true)

func _draw_timber(a: Vector2, b: Vector2, thickness: float) -> void:
	draw_line(a, b, WOOD_DARK, thickness + 4.0, true)
	draw_line(a, b, WOOD_EDGE, thickness, true)
	draw_line(a + Vector2(-1, -1), b + Vector2(-1, -1), WOOD_FACE, thickness * 0.65, true)
	draw_line(a + Vector2(-2, -2), b + Vector2(-2, -2), WOOD_LIGHT, 1.3, true)

func _draw_post(x: float, top: float, floor_y: float) -> void:
	_draw_timber(Vector2(x, top), Vector2(x, floor_y + 6.0), 17.0)
	# Small masonry shoes tie the timber to the landing instead of leaving it floating.
	var foot := PackedVector2Array([Vector2(x - 13, floor_y - 7), Vector2(x + 13, floor_y - 7), Vector2(x + 17, floor_y - 3), Vector2(x + 17, floor_y + 9), Vector2(x - 17, floor_y + 9), Vector2(x - 17, floor_y - 3)])
	draw_colored_polygon(foot, Color("aaa6aa"))
	draw_line(Vector2(x - 13, floor_y - 6), Vector2(x + 13, floor_y - 6), Color("e3dbbf"), 3.0, true)
	draw_line(Vector2(x - 17, floor_y + 9), Vector2(x + 17, floor_y + 9), Color("807e91"), 2.0, true)
	for y in [top + 16.0, floor_y - 20.0]:
		draw_line(Vector2(x - 10, y), Vector2(x + 10, y), METAL_DARK, 7.0, true)
		draw_line(Vector2(x - 9, y - 1), Vector2(x + 9, y - 1), METAL_GOLD, 2.0, true)
		draw_circle(Vector2(x, y), 2.2, Color("fff0bd"))

func _draw_pulley(center: Vector2, angle: float, radius: float, painted: bool) -> void:
	if not painted:
		draw_circle(center, radius + 1.0, WOOD_DARK)
		draw_circle(center, radius * 0.88, METAL_GOLD)
		draw_arc(center, radius * 0.69, 0.0, TAU, 24, METAL_DARK, 2.0, true)
	for i in 4:
		var spoke := Vector2.from_angle(angle + i * PI * 0.5) * radius * 0.69
		draw_line(center, center + spoke, Color("f2ce78"), 1.8, true)
	draw_circle(center, radius * 0.27, METAL_DARK)
	draw_circle(center + Vector2(-1, -1), radius * 0.115, Color("fff0bf"))

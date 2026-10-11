@tool
extends "res://scripts/story_interaction.gd"
## Socket coordinates are measured per cutout, not shared between unrelated drawings.
const WORLD_GEAR = preload("res://assets/environment/worlds/common/gear.png")

func _draw_repair() -> void:
	if not used and (not is_instance_valid(actor) or progress < 0.18): return
	var socket := socket_position()
	var width := picture_height * picture.get_width() / float(picture.get_height()) * repair_gear_width
	var fitted := Vector2(width, width * WORLD_GEAR.get_height() / float(WORLD_GEAR.get_width()))
	var center := socket
	var turn := 0.0
	var opacity := 1.0
	if not used:
		var insert := smoothstep(0.30, 0.85, progress)
		var hand := to_local(actor.global_position) + Vector2(actor.facing * 27, -44)
		center = hand.lerp(socket, insert) + Vector2(0, -sin(insert * PI) * 9)
		turn = (1.0 - insert) * -0.65
		opacity = smoothstep(0.18, 0.30, progress)
	draw_set_transform(center, turn)
	draw_circle(Vector2.ZERO, fitted.x * 0.15, Color("6b4931"))
	draw_texture_rect(WORLD_GEAR, Rect2(-fitted * 0.5, fitted), false, Color(1, 1, 1, opacity))
	draw_set_transform(Vector2.ZERO)

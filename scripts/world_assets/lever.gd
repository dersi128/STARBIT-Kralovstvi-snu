@tool
extends "res://scripts/story_interaction.gd"
## Uses Bit's existing interaction animation; its own art has separate aligned pivots.
const WORLD_BASE = preload("res://assets/environment/worlds/common/lever_base.png")
const WORLD_HANDLE = preload("res://assets/environment/worlds/common/lever_handle.png")

func _draw() -> void:
	var size := Vector2(72, 72.0 * WORLD_BASE.get_height() / WORLD_BASE.get_width())
	var base_rect := Rect2(Vector2(-36, -size.y), size)
	var pivot := base_rect.position + size * Vector2(0.50, 0.275)
	var turn := 0.65 if used else -0.65
	if is_instance_valid(actor): turn = lerpf(-0.65, 0.65, smoothstep(0.2, 0.85, progress))
	draw_texture_rect(WORLD_BASE, base_rect, false)
	var handle_size := Vector2(76.0 * WORLD_HANDLE.get_width() / WORLD_HANDLE.get_height(), 76)
	draw_set_transform(pivot, turn)
	draw_texture_rect(WORLD_HANDLE, Rect2(-handle_size * Vector2(0.50, 0.86), handle_size), false)
	draw_set_transform(Vector2.ZERO)
	if focus and not used:
		draw_string(FONT, Vector2(-42, -125), "E · Aktivovat", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("fff8de"))

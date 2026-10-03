@tool
extends "res://scripts/dream_switch.gd"
## A painted sun, moon or star uses the same grounded activation as other plates.
@export var seal_texture: Texture2D:
	set(value): seal_texture = value; queue_redraw()

func _ready() -> void:
	super._ready()
	z_index = -1

func _draw() -> void:
	if seal_texture == null:
		super._draw()
		return
	var size := seal_texture.get_size() * (100.0 / seal_texture.get_height())
	var ink := Color.WHITE if active else Color(0.60, 0.65, 0.77)
	draw_texture_rect(seal_texture, Rect2(Vector2(-size.x / 2, -100), size), false, ink)
	if active:
		var centre := Vector2(0, -62)
		draw_arc(centre, 27 + sin(glow_time * 3) * 2, 0, TAU, 28, Color(1, 0.90, 0.48, 0.65), 2, true)
		for i in 3:
			var age := fposmod(glow_time * 0.3 + i / 3.0, 1.0)
			draw_circle(centre + Vector2((i - 1) * 15, -age * 32), 1.8, Color(1, 0.97, 0.67, sin(age * PI) * 0.7))

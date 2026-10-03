@tool
extends Node2D
## Decorative restoration only: the origin is the existing terrace's walk line.
@export var dry_texture: Texture2D
@export var lush_texture: Texture2D
@export var art_width := 156.0
var growth := 0.0

func set_growth(amount: float) -> void:
	growth = clampf(amount, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	if dry_texture != null and growth < 1.0:
		_draw_grounded(dry_texture, 1.0 - growth)
	if lush_texture != null and growth > 0.0:
		_draw_grounded(lush_texture, growth)

func _draw_grounded(texture: Texture2D, opacity: float) -> void:
	var art_height := art_width * texture.get_height() / maxf(texture.get_width(), 1.0)
	draw_texture_rect(texture, Rect2(-art_width / 2, -art_height + 2.0, art_width, art_height), false, Color(1, 1, 1, opacity))

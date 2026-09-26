@tool
extends "res://scripts/platform.gd"
## Shared STARBIT palette. This renderer keeps the existing width, motion and collisions.
@export_enum("grass", "wood", "stone") var surface_art := "grass":
	set(value):surface_art = value;queue_redraw()
const ATLAS = preload("res://assets/world_expansion/platforms_starbit_v2.png")
# The generated atlas is packed, not a uniform animation grid. Explicit regions avoid neighbouring sprites.
# Entries: first row y/height/walk line, second row y/height/walk line.
const ROWS = {
	"grass": [28.0, 179.0, 87.0, 207.0, 196.0, 260.0],
	"wood": [403.0, 140.0, 447.0, 543.0, 161.0, 586.0],
	"stone": [704.0, 166.0, 748.0, 870.0, 210.0, 920.0]
}

func draw_frame(frame: int) -> void:
	var index := clampi(frame, 0, 7)
	var row: Array = ROWS.get(surface_art, ROWS.grass)
	var offset := 3 if index >= 4 else 0
	var top: float = row[offset]
	var height: float = row[offset + 1]
	var surface_y: float = row[offset + 2]
	var factor := width / 308.0
	# Only broken chunks fall; intact and warning frames remain fixed at the collision surface.
	var fall := maxf(0.0, index - 3.0) * 12.0 * factor
	var opacity := 1.0 if index < 4 else 1.0 - (index - 4) * 0.18
	var source := Rect2((index % 4) * 362, top, 362, height)
	var destination := Rect2(-31 * factor, -(surface_y - top) * factor + fall, 362 * factor, height * factor)
	draw_texture_rect_region(ATLAS, destination, source, Color(1, 1, 1, opacity))

func _draw() -> void:
	draw_frame(0)
	if Engine.is_editor_hint() and travel.length() > 0:
		draw_line(Vector2(width / 2, 0), Vector2(width / 2, 0) + travel, Color.CYAN, 2)

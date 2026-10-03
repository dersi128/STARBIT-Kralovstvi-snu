@tool
extends Node2D
## Decorative masonry: supports the silhouette of a room without blocking its passage.
## Position is the upper-left corner; openings are local rectangles through the back wall.
@export var size := Vector2(900, 500):
	set(value): size = value; queue_redraw()
@export var tint := Color(0.66, 0.68, 0.79, 0.96):
	set(value): tint = value; queue_redraw()
@export var openings: Array[Rect2] = []:
	set(value): openings = value; queue_redraw()
@export var crenellated := false:
	set(value): crenellated = value; queue_redraw()
const WALL = preload("res://assets/royal/castle_wall.png")
const TILE := Vector2(360, 262.39234)
const SOURCE := Vector2(1254, 914)

func _ready() -> void:
	z_index = -20
	queue_redraw()

func _pieces_around(rect: Rect2, hole: Rect2) -> Array[Rect2]:
	if not rect.intersects(hole): return [rect]
	var cut := rect.intersection(hole)
	var pieces: Array[Rect2] = []
	for piece in [
		Rect2(rect.position, Vector2(rect.size.x, cut.position.y - rect.position.y)),
		Rect2(Vector2(rect.position.x, cut.end.y), Vector2(rect.size.x, rect.end.y - cut.end.y)),
		Rect2(Vector2(rect.position.x, cut.position.y), Vector2(cut.position.x - rect.position.x, cut.size.y)),
		Rect2(Vector2(cut.end.x, cut.position.y), Vector2(rect.end.x - cut.end.x, cut.size.y))]:
		if piece.size.x > 0 and piece.size.y > 0: pieces.append(piece)
	return pieces

func _draw() -> void:
	if size.x <= 0 or size.y <= 0: return
	for row in ceili(size.y / TILE.y):
		for col in ceili(size.x / TILE.x):
			var origin := Vector2(col, row) * TILE
			var cell := Rect2(origin, (size - origin).min(TILE))
			var pieces: Array[Rect2] = [cell]
			for hole in openings:
				var next: Array[Rect2] = []
				for piece in pieces: next.append_array(_pieces_around(piece, hole))
				pieces = next
			for piece in pieces:
				draw_texture_rect_region(WALL, piece, Rect2((piece.position - origin) * SOURCE / TILE, piece.size * SOURCE / TILE), tint)
	# The light upper edge helps distinguish the wall behind Bit from walkable foreground.
	draw_line(Vector2.ZERO, Vector2(size.x, 0), tint.lightened(0.12), 5)
	if crenellated:
		for i in ceili(size.x / 115.0):
			var x := i * 115.0
			var span := minf(62.0, size.x - x)
			draw_texture_rect_region(WALL, Rect2(x, -38, span, 38), Rect2(12, 18, 216 * span / 62.0, 133), tint)

@tool
extends Node2D
## Separate ropes, fixed header and moving deck. Edit Deck.travel for lift height.
@export var rope_half_width := 70.0

func set_powered(value: bool) -> void:
	$Deck.set_powered(value)

func _process(_delta: float) -> void:
	for pair in [[get_node("RopeLeft"), -rope_half_width], [get_node("RopeRight"), rope_half_width]]:
		var rope: Line2D = pair[0]
		var x: float = pair[1]
		rope.points = PackedVector2Array([Vector2(x, $Header.position.y + 12), $Deck.position + Vector2(x, 8)])

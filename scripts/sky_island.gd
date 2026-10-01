@tool
extends AnimatableBody2D
## Only used by levels 6–7. Art keeps its proportions and its grassy walk line.
@export var width := 570.0:
	set(value):width=maxf(value,120);queue_redraw()
@export var depth := 95.0
const ART = preload("res://assets/pieces/island.png")
func _ready() -> void:
	collision_layer=1
	collision_mask=0
func _draw() -> void:
	var scale_factor:float=(width+36)/282.0
	# Exclude the stray fragment along the bottom of the original atlas piece.
	draw_texture_rect_region(ART,Rect2(-18,-34*scale_factor,282*scale_factor,145*scale_factor),Rect2(8,0,282,145))

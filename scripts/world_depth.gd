@tool
extends Node
## Per-level overrides leave shared backgrounds for levels 6–10 untouched.
@export var background_path := NodePath("../Background")
@export_range(0.01, 0.2, 0.01) var distant_motion := 0.03
@export var atmosphere := Color.WHITE

func _ready() -> void:
	var background := get_node_or_null(background_path)
	if background == null:return
	var far := background.get_node_or_null("far") as Parallax2D
	if far != null:
		far.scroll_scale = Vector2(distant_motion, 0)
		far.modulate = atmosphere
	# Repeating foreground bushes make landmarks look identical; authored local props replace them.
	var front := background.get_node_or_null("front") as CanvasItem
	if front != null:front.visible = false

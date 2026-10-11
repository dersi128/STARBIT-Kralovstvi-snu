@tool
extends "res://scripts/story_interaction.gd"
## Reuses the repair/activation poses and existing painted props.
@export var aftermath := ""
@export var light_radius := 310.0

func complete_interaction(player: CharacterBody2D) -> void:
	var already_used := used
	super(player)
	if not already_used and used:
		var level := get_tree().get_first_node_in_group("level")
		if level != null and level.has_node("MorousDarkness"):
			level.get_node("MorousDarkness").add_safe_light(global_position, light_radius)
		if not aftermath.is_empty():
			get_tree().call_group("game", "show_chapter_message", "Bit", aftermath, "idle")

func _draw() -> void:
	super()
	if used and action != "pickup":
		for i in range(4):
			draw_circle(Vector2(0, -picture_height * 0.55), 24.0 + i * 13.0, Color(1, 0.86, 0.39, 0.035))

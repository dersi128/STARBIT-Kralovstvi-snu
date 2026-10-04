@tool
extends "res://scripts/level.gd"
## The final portal only opens after Jiskra's rescue dialogue is confirmed.
func can_finish_level() -> bool:
	var cage := get_node_or_null("JiskraCage")
	return cage != null and cage.rescued

func check_portal_contact(previous:Vector2,current:Vector2) -> bool:
	if not can_finish_level():return false
	return super.check_portal_contact(previous,current)

func respawn_player() -> void:
	super.respawn_player()
	var cage := get_node_or_null("JiskraCage")
	if cage != null:cage.reset_interrupted_rescue()

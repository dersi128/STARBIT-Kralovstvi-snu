extends StaticBody2D
@export_range(0.3, 4.0, 0.1) var warning_seconds := 1.0
@export_range(1.0, 12.0, 0.1) var return_seconds := 3.5
var timer := -1.0
var absent := false

func _physics_process(delta: float) -> void:
	if timer < 0.0:
		for player in get_tree().get_nodes_in_group("player"):
			if player is CharacterBody2D and player.is_on_floor():
				for i in player.get_slide_collision_count():
					if player.get_slide_collision(i).get_collider() == self:
						timer = warning_seconds
		return
	timer -= delta
	if not absent:
		$Visual.rotation = sin(timer * 45.0) * 0.012
		$Visual.modulate = Color(1, 0.8 + 0.2 * absf(sin(timer * 15)), 0.7)
	if timer > 0.0: return
	absent = not absent
	$Collision.set_deferred("disabled", absent)
	$Visual.visible = not absent
	$Visual.rotation = 0.0
	$Visual.modulate = Color.WHITE
	timer = return_seconds if absent else -1.0

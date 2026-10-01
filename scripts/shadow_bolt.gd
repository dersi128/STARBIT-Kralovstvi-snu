extends Node2D
## A visible, straight shadow spell. Swept collision prevents tunnelling through walls.
var caster: Node2D
var target: Node2D
var target_deaths := 0
var velocity := Vector2(230, 0)
var remaining_distance := 620.0
var age := 0.0
var impact_age := -1.0

func _ready() -> void:
	z_index = 4
	add_to_group("shadow_bolts")

func _physics_process(delta: float) -> void:
	age += delta
	if not is_instance_valid(caster) or caster.defeated or not is_instance_valid(target) or target.deaths != target_deaths:
		queue_free()
		return
	if impact_age >= 0.0:
		impact_age += delta
		if impact_age >= 0.16:queue_free()
		queue_redraw()
		return
	var step := velocity * delta
	var next := global_position + step
	# Layer 1: world, 2: Bit, 4: movable crates. Hit only the first obstacle.
	var query := PhysicsRayQueryParameters2D.create(global_position, next, 7)
	query.hit_from_inside = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		global_position = hit.position
		impact_age = 0.0
		var body: Node = hit.collider
		if body.is_in_group("player") and body.has_method("hurt"):body.hurt()
	else:
		global_position = next
		remaining_distance -= step.length()
		if remaining_distance <= 0 or age >= 6.0:queue_free()
	queue_redraw()

func _draw() -> void:
	if impact_age >= 0.0:
		var fade := 1.0 - impact_age / 0.16
		draw_arc(Vector2.ZERO, 10 + impact_age * 90, 0, TAU, 24, Color(0.82,0.54,1,fade), 3, true)
		return
	var heading := velocity.normalized()
	for i in range(5, 0, -1):
		var tail := -heading * float(i) * 7 + Vector2(0, sin(age*17-i)*2)
		draw_circle(tail, 10-float(i), Color(0.51,0.22,0.85,0.38-float(i)*0.045))
	draw_circle(Vector2.ZERO, 17, Color(0.57,0.27,0.91,0.16))
	draw_circle(Vector2.ZERO, 10, Color("8038c5"))
	draw_arc(Vector2.ZERO, 11, 0, TAU, 24, Color("db9dff"), 2, true)
	draw_circle(-heading*2, 4, Color("f8eaff"))

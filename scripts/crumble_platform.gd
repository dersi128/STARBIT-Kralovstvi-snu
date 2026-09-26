@tool
extends "res://scripts/dream_platform.gd"
## Three warning frames, then falling debris. Collision disappears exactly when the surface splits.
@export_range(0.5, 3.0, 0.1) var crumble_delay := 1.1
@export_range(1.5, 8.0, 0.1) var return_delay := 3.2
var countdown := -1.0
var absent := false

func _physics_process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint():return
	if countdown < 0.0:
		var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
		if player != null and player.is_on_floor():
			for i in player.get_slide_collision_count():
				if player.get_slide_collision(i).get_collider() == self:
					countdown = crumble_delay
					break
	else:
		countdown -= delta
		if countdown <= 0.0:
			if absent:
				absent = false
				countdown = -1.0
				$CollisionShape2D.set_deferred("disabled", false)
			else:
				absent = true
				countdown = return_delay
				$CollisionShape2D.set_deferred("disabled", true)
	queue_redraw()

func _draw() -> void:
	if absent:
		var elapsed := return_delay - countdown
		if elapsed < 0.55:draw_frame(4 + mini(3, int(elapsed / 0.14)))
		elif countdown < 0.7:
			draw_line(Vector2(8, 0), Vector2(width - 8, 0), Color(0.7, 0.95, 1.0, 0.5), 3, true)
		return
	var frame := 0 if countdown < 0.0 else mini(3, 1 + int((1.0 - countdown / crumble_delay) * 3.0))
	draw_frame(frame)
	# A small crack identifies a fragile platform even before stepping onto it.
	if frame == 0:
		draw_polyline(PackedVector2Array([Vector2(width * 0.52, -5), Vector2(width * 0.48, 2), Vector2(width * 0.53, 9)]), Color(0.24, 0.17, 0.12, 0.8), 2, true)

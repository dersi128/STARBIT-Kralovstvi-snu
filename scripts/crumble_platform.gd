@tool
extends "res://scripts/platform.gd"
## Cracks after Bit lands; returns automatically so a retry is always possible.
@export_range(0.5, 3.0, 0.1) var crumble_delay := 1.1
@export_range(1.5, 8.0, 0.1) var return_delay := 3.2
var countdown := -1.0
var absent := false
var resting_tint := Color.WHITE

func _ready() -> void:
	super()
	resting_tint = modulate

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
		return
	countdown -= delta
	if absent:
		modulate = Color(resting_tint, 0.18 * clampf(1.0 - countdown / return_delay, 0.0, 1.0))
		if countdown <= 0.0:
			absent = false
			countdown = -1.0
			$CollisionShape2D.set_deferred("disabled", false)
			modulate = resting_tint
	else:
		var warning := 1.0 - clampf(countdown / crumble_delay, 0.0, 1.0)
		modulate = resting_tint.lerp(Color(1.0, 0.68, 0.35), warning * 0.65)
		if countdown <= 0.0:
			absent = true
			countdown = return_delay
			$CollisionShape2D.set_deferred("disabled", true)
			modulate.a = 0.0
	queue_redraw()

func _draw() -> void:
	super()
	# A permanent crack distinguishes these surfaces before the first landing.
	var mid := width * 0.5
	var depth_hint := 18.0
	if countdown >= 0.0 and not absent:
		depth_hint += 16.0 * (1.0 - clampf(countdown / crumble_delay, 0.0, 1.0))
	draw_polyline(PackedVector2Array([Vector2(mid - 10, -5), Vector2(mid + 2, 3), Vector2(mid - 6, 12), Vector2(mid + 8, depth_hint)]), Color(0.25, 0.16, 0.13, 0.9), 3.0, true)

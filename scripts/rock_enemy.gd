@tool
extends "res://scripts/enemy.gd"
## Šutřík shares enemy interactions; only its grounded patrol differs.
const WalkVisual = preload("res://scripts/rock_walk_visual.gd")
const WALK_CYCLE_DISTANCE := WalkVisual.STRIDE
var _body: CharacterBody2D
var _walk_phase := 0.0
var _actual_speed := 0.0
var _floor_offset := 0.0
var _floor_normal := Vector2.UP
var _needs_grounding := true
var _walk_visual: Node2D
var _step_delta := 1.0 / 60.0

func _ready() -> void:
	_body = get_node(".") as CharacterBody2D
	super()
	if not Engine.is_editor_hint():
		_walk_visual = WalkVisual.new()
		_walk_visual.name = "GroundedWalk"
		_walk_visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		_walk_visual.reset_facing(direction)
		add_child(_walk_visual)

func _move_patrol(delta: float) -> void:
	_step_delta = delta
	if _needs_grounding:
		_needs_grounding = false
		_place_on_ground()
	var previous := global_position
	var grounded := _body.is_on_floor()
	_body.velocity.y = 0.0 if grounded else minf(_body.velocity.y + 1450.0 * delta, 1000.0)
	var walking := patrol > 0.0 and absf(speed) > 0.1
	var bounds := _patrol_bounds()
	if walking and turn_time <= 0.0:
		var at_end := position.x >= bounds.y if direction > 0 else position.x <= bounds.x
		if at_end or (grounded and not _ground_ahead(delta)):
			_turn_around()
	_body.velocity.x = 0.0
	if walking and turn_time <= 0.0:
		var remaining := bounds.y - position.x if direction > 0 else position.x - bounds.x
		_body.velocity.x = direction * minf(absf(speed), maxf(remaining, 0.0) / maxf(delta, 0.001))
	_body.move_and_slide()
	if _body.is_on_wall() and turn_time <= 0.0:
		_turn_around()
	_actual_speed = 0.0
	_floor_offset = 0.0
	if _body.is_on_floor():
		_update_floor_contact()
		var floor_up := maxf(-_floor_normal.y, 0.01)
		var travel := global_position - previous - _body.get_platform_velocity() * delta
		var distance := absf(travel.x) / floor_up
		_actual_speed = distance / maxf(delta, 0.001)
		_walk_phase = fposmod(_walk_phase + distance / WALK_CYCLE_DISTANCE, 1.0)

func _update_floor_contact() -> void:
	_floor_normal = _body.get_floor_normal()
	var shape: CapsuleShape2D = $Collision.shape
	_floor_offset = shape.radius * (1.0 / maxf(-_floor_normal.y, 0.01) - 1.0)
	# Use the actual surface for the soles: capsule contact normals can jitter.
	var probe := PhysicsRayQueryParameters2D.create(
		global_position + Vector2(0, -24), global_position + Vector2(0, 32),
		_body.collision_mask, [_body.get_rid()])
	var hit := get_world_2d().direct_space_state.intersect_ray(probe)
	if not hit.is_empty() and hit.normal.dot(Vector2.UP) >= cos(_body.floor_max_angle):
		_floor_normal = hit.normal
		_floor_offset = to_local(hit.position).y

func _place_on_ground() -> void:
	# Authored enemies can start a few pixels inside a one-way platform.
	# Resolve that once, before movement, so they do not drop through its top.
	var probe := PhysicsRayQueryParameters2D.create(
		global_position + Vector2(0, -48), global_position + Vector2(0, 32),
		_body.collision_mask, [_body.get_rid()])
	var hit := get_world_2d().direct_space_state.intersect_ray(probe)
	if hit.is_empty() or hit.normal.dot(Vector2.UP) < cos(_body.floor_max_angle):
		return
	var shape: CapsuleShape2D = $Collision.shape
	var clearance := shape.radius * (1.0 / maxf(-hit.normal.y, 0.01) - 1.0)
	global_position.y = hit.position.y - clearance - _body.safe_margin - 1.0

func _ground_ahead(delta: float) -> bool:
	var shape: CapsuleShape2D = $Collision.shape
	var ahead := shape.radius * absf(global_scale.x) + 4.0 + absf(speed) * delta
	var reach := ahead + 8.0
	var probe := PhysicsRayQueryParameters2D.create(
		global_position + Vector2(direction * ahead, -reach),
		global_position + Vector2(direction * ahead, reach),
		_body.collision_mask, [_body.get_rid()])
	var hit := get_world_2d().direct_space_state.intersect_ray(probe)
	return not hit.is_empty() and hit.normal.dot(Vector2.UP) >= cos(_body.floor_max_angle)

func _turn_around() -> void:
	direction *= -1.0
	turn_time = WalkVisual.TURN_DURATION

func _walking_speed() -> float:
	return _actual_speed

func _animate() -> void:
	super()
	if anim == null:
		return
	anim.position.y = _floor_offset
	if _walk_visual == null:
		return
	var grounded := _body.is_on_floor()
	var use_walk := grounded and not defeated and attack_cooldown <= 0.0
	_walk_visual.visible = use_walk
	anim.visible = not use_walk
	if grounded and not defeated:
		var normal := global_transform.basis_xform_inv(_floor_normal).normalized()
		_walk_visual.position.y = _floor_offset
		_walk_visual.update_pose(_walk_phase, _actual_speed > 0.1, direction,
			normal.x / maxf(-normal.y, 0.01), _step_delta)
	if use_walk:
		anim.pause()

func _draw() -> void:
	if Engine.is_editor_hint() or _body == null:
		super()
	elif not defeated and _body.is_on_floor():
		var normal := global_transform.basis_xform_inv(_floor_normal).normalized()
		draw_set_transform(Vector2(0, _floor_offset + 1), normal.angle() + PI * 0.5, Vector2(1, 0.14))
		draw_circle(Vector2.ZERO, 26, Color(0.1, 0.1, 0.25, 0.15))
		draw_set_transform(Vector2.ZERO)

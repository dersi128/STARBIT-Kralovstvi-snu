extends Node2D
## Stable torso and two feet sampled from the original art, without morphing frames.
const SHEET: Texture2D = preload("res://assets/animations/rock_enemy.png")
const ART_SCALE := 0.30
const STRIDE := 56.0
const STANCE := 0.60
const TURN_DURATION := 0.28
const BODY := Rect2(14, 42, 299, 232)
const FEET: Array[Rect2] = [Rect2(59, 272, 94, 44), Rect2(179, 274, 87, 42)]
const PIVOTS: Array[Vector2] = [Vector2(107, 315), Vector2(222, 315)]
var phase := 0.0
var weight := 0.0
var facing := 1.0
var floor_slope := 0.0
var clock := 0.0
var _turn_age := TURN_DURATION
var _turn_from := 1.0
var _turn_to := 1.0
var _turn_feet: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]

func update_pose(walk_phase: float, moving: bool, direction: float, slope: float, delta: float) -> void:
	if direction != _turn_to:
		# Capture the planted feet before shifting weight. No interpolation of
		# signed scale: that used to flatten the whole character to zero width.
		var current := pose_parts()
		for index in 2:
			var foot_position: Vector2 = current[index].position
			_turn_feet[index] = foot_position.rotated(-atan(floor_slope))
		_turn_from = facing
		_turn_to = direction
		_turn_age = 0.0
	else:
		_turn_age = minf(_turn_age + delta, TURN_DURATION)
	phase = walk_phase
	weight = move_toward(weight, 1.0 if moving else 0.0, delta * 8.0)
	# Turn the torso at the weight transfer, keeping its full stone volume.
	facing = _turn_to if _turn_age >= TURN_DURATION * 0.5 else _turn_from
	floor_slope = slope
	clock += delta
	queue_redraw()

func pose_parts() -> Array[Dictionary]:
	var parts: Array[Dictionary] = []
	var turning := _turn_age < TURN_DURATION
	var turn_progress := clampf(_turn_age / TURN_DURATION, 0.0, 1.0)
	for index in 2:
		var step := fposmod(phase + index * 0.5, 1.0)
		var stride_x := STRIDE * (STANCE * 0.5 - step)
		var lift := 0.0
		if step > STANCE:
			var swing := (step - STANCE) / (1.0 - STANCE)
			stride_x = STRIDE * STANCE * (smoothstep(0.0, 1.0, swing) - 0.5)
			lift = sin(PI * swing) * 4.0
		var rest_x := (PIVOTS[index].x - 163.5) * ART_SCALE
		var base_x := -8.0 if index == 0 else 8.0
		var x := lerpf(rest_x, base_x + stride_x, weight) * facing
		var foot_angle := atan(floor_slope)
		var foot_position := Vector2(x, -lift * weight).rotated(foot_angle)
		var foot_facing := facing
		if turning:
			# One foot supports the body while the other takes a small pivot
			# step. Their paths meet at different times, instead of collapsing.
			var foot_progress := clampf(turn_progress * 2.0 - float(index), 0.0, 1.0)
			var pivot_blend := smoothstep(0.0, 1.0, foot_progress)
			var target := Vector2(rest_x * _turn_to, 0.0)
			var pivot_position := _turn_feet[index].lerp(target, pivot_blend)
			pivot_position.y -= sin(foot_progress * PI) * 3.0
			foot_position = pivot_position.rotated(foot_angle)
			foot_facing = _turn_to if foot_progress >= 0.5 else _turn_from
		# Flat soles stay on the surface; only the returning foot lifts.
		var foot_rect := Rect2(FEET[index].position - PIVOTS[index], FEET[index].size)
		parts.append({"region": FEET[index], "rect": foot_rect, "position": foot_position,
			"rotation": foot_angle, "scale": Vector2(ART_SCALE * foot_facing, ART_SCALE)})
	var sway := sin(phase * TAU) * weight
	var settle := (0.5 - 0.5 * cos(phase * TAU * 2.0)) * weight
	var body_position := Vector2(sway * 0.55, settle * 0.65 + sin(clock * 2.0) * 0.18 * (1.0 - weight))
	var body_angle := sway * 0.012
	if turning:
		var transfer := sin(turn_progress * TAU)
		body_position += Vector2(_turn_from * transfer * 1.8, sin(turn_progress * PI) * 1.2)
		body_angle += _turn_from * transfer * 0.035
	parts.append({"region": BODY, "rect": Rect2(BODY.position - Vector2(163.5, 315), BODY.size),
		"position": body_position.rotated(atan(floor_slope)), "rotation": body_angle + atan(floor_slope),
		"scale": Vector2(ART_SCALE * facing, ART_SCALE)})
	return parts

func _draw() -> void:
	for part in pose_parts():
		draw_set_transform(part.position, part.rotation, part.scale)
		draw_texture_rect_region(SHEET, part.rect, part.region)
	draw_set_transform(Vector2.ZERO)

extends AnimatableBody2D
## Origin is the walkable top. Physics movement carries CharacterBody2D riders.
@export var travel := Vector2(0, -180)
@export_range(0.5, 12.0, 0.1) var period := 4.0
@export_enum("Loop", "Powered endpoint") var motion_kind := 0
@export var powered := true
var origin := Vector2.ZERO
var phase := 0.0

func _ready() -> void:
	origin = position

func set_powered(value: bool) -> void:
	powered = value

func _physics_process(delta: float) -> void:
	var fraction: float
	if motion_kind == 0:
		if powered: phase = fposmod(phase + delta / period, 1.0)
		fraction = (1.0 - cos(phase * TAU)) * 0.5
	else:
		phase = move_toward(phase, 1.0 if powered else 0.0, delta / period)
		fraction = smoothstep(0.0, 1.0, phase)
	position = origin + travel * fraction

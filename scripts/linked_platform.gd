@tool
extends "res://scripts/dream_platform.gd"
## Plate-controlled lift. Waiting at either end never requires a frame-perfect jump.
@export var powered := false
@export_range(0.5, 6.0, 0.1) var move_seconds := 2.0
var extension := 0.0

func set_powered(value: bool) -> void:
	powered = value

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():return
	extension = move_toward(extension, 1.0 if powered else 0.0, delta / maxf(0.5, move_seconds))
	position = origin + travel * smoothstep(0.0, 1.0, extension)

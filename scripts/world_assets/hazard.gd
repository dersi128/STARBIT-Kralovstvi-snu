extends Area2D
signal triggered(body: Node2D)
@export var active := true
@export_range(0.1, 3.0, 0.1) var hit_interval := 0.7
var cooldown := 0.0

func set_powered(value: bool) -> void:
	active = value
	$Visual.modulate.a = 1.0 if active else 0.4

func _physics_process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	if not active or cooldown > 0.0: return
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("hurt"):
			body.hurt()
			triggered.emit(body)
			cooldown = hit_interval
			break

extends Area2D
signal switched(powered: bool)
@export var targets: Array[NodePath] = []
@export var latch := true
var pressed := false
var visual_origin := Vector2.ZERO

func _ready() -> void:
	visual_origin = $Visual.position

func _physics_process(_delta: float) -> void:
	var occupied := false
	for body in get_overlapping_bodies():
		if body.is_in_group("player") or body.is_in_group("push_crates"):
			occupied = true
	if latch and pressed: return
	set_pressed(occupied)

func set_pressed(value: bool) -> void:
	if pressed == value: return
	pressed = value
	$Visual.position = visual_origin + Vector2(0, 3 if value else 0)
	$Visual.modulate = Color("c4ffeb") if value else Color.WHITE
	for path in targets:
		var target := get_node_or_null(path)
		if target != null and target.has_method("set_powered"):
			target.set_powered(value)
	switched.emit(value)

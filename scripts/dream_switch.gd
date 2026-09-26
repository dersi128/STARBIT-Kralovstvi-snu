@tool
extends Node2D
## Place at the walk line. Player and crates use their feet, so jumping over it does not trigger it.
@export var targets: Array[NodePath] = []
@export var latch := true
@export var require_crate := false
@export var release_grace := 1.5
@export var plate_width := 100.0
@export_enum("plate", "crystal") var appearance := "plate"
var active := false
var grace := 0.0
var glow_time := 0.0
const SHEET = preload("res://assets/world_expansion/switches.png")

func _ready() -> void:
	z_index = 1
	queue_redraw()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():return
	var occupied := false
	var bodies := get_tree().get_nodes_in_group("push_crates")
	if not require_crate:bodies.append_array(get_tree().get_nodes_in_group("player"))
	for body in bodies:
		if not body is CharacterBody2D or not body.is_on_floor():continue
		var feet := to_local(body.global_position)
		if absf(feet.x) < plate_width * 0.5 and absf(feet.y) < 12.0:
			occupied = true
			break
	if occupied:grace = release_grace
	else:grace = maxf(0.0, grace - delta)
	var next := occupied or grace > 0.0 or (latch and active)
	if next != active:
		active = next
		for path in targets:
			var target := get_node_or_null(path)
			if target != null and target.has_method("set_powered"):target.set_powered(active)
		if active:Progress.sfx("checkpoint")
	glow_time += delta
	queue_redraw()

func _draw() -> void:
	if appearance == "crystal":
		draw_texture_rect_region(SHEET, Rect2(-38, -82, 76, 95), Rect2(241 * (5 if active else 0), 322, 240, 307))
	else:
		draw_texture_rect_region(SHEET, Rect2(-plate_width / 2, -35, plate_width, 56), Rect2(724 if active else (362 if require_crate else 0), 640, 362, 202))
	if active:
		draw_arc(Vector2(0, -8), plate_width * 0.36, PI, TAU, 20, Color(1, 0.87, 0.35, 0.45 + 0.15 * sin(glow_time * 3)), 2, true)

@tool
extends Node2D
## Place at the walk line. Player and crates use their feet, so jumping over it does not trigger it.
@export var targets: Array[NodePath] = []
@export var latch := true
@export var require_crate := false:
	set(value):require_crate=value;_sync_plate()
@export var release_grace := 1.5
@export var plate_width := 100.0:
	set(value):plate_width=value;_sync_plate()
## Výška vzhledu nad aktivačním bodem. Větší číslo zvedne tlačítko; detekce zůstává na povrchu země.
## Celé tlačítko včetně detekce přesuň pomocí Transform > Position tohoto uzlu.
@export_range(-80.0, 120.0, 1.0, "or_less", "or_greater") var plate_visual_height := 18.0:
	set(value):plate_visual_height=value;_sync_plate()
@export_enum("plate", "crystal") var appearance := "plate":
	set(value):appearance=value;_sync_plate();queue_redraw()
var active := false
var grace := 0.0
var glow_time := 0.0
const PLATE_VISUAL = preload("res://scripts/pressure_plate_visual.gd")
const SHEET = preload("res://assets/world_expansion/switches.png")

func _ready() -> void:
	z_index = 1
	_sync_plate()
	queue_redraw()

func _sync_plate() -> void:
	if not is_inside_tree():return
	# Resolve by node path instead of retaining a script member across tool reloads.
	var plate := get_node_or_null(^"PressurePlateVisual")
	if plate == null:
		plate = PLATE_VISUAL.new()
		plate.name = "PressurePlateVisual"
		add_child(plate, false, Node.INTERNAL_MODE_BACK)
	plate.position = Vector2(0, -plate_visual_height)
	plate.width = plate_width
	plate.active = active
	plate.requires_crate = require_crate
	plate.visible = appearance == "plate"
	plate.z_as_relative = false
	plate.z_index = 1
	plate.queue_redraw()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		# Recover the preview after script replacement in an already-open scene.
		if not has_node(^"PressurePlateVisual"):_sync_plate()
		return
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
		_sync_plate()
		for path in targets:
			var target := get_node_or_null(path)
			if target != null and target.has_method("set_powered"):target.set_powered(active)
		if active:Progress.sfx("checkpoint")
	glow_time += delta
	queue_redraw()

func _draw() -> void:
	if appearance == "crystal":
		draw_texture_rect_region(SHEET, Rect2(-38, -82, 76, 95), Rect2(241 * (5 if active else 0), 322, 240, 307))
	if active and appearance == "crystal":
		draw_arc(Vector2(0, -8), plate_width * 0.36, PI, TAU, 20, Color(1, 0.87, 0.35, 0.45 + 0.15 * sin(glow_time * 3)), 2, true)

@tool
extends StaticBody2D
## Bottom-centred seal. Every linked switch must be active; progress survives respawns.
## Sources may be latching plates, mirrors, or another royal lock.
@export var sources: Array[NodePath] = []
@export var gate_size := Vector2(72, 600):
	set(value):
		gate_size = Vector2(maxf(40, value.x), maxf(120, value.y))
		if is_node_ready(): _sync_shape()
		queue_redraw()
@export var latched := true
@export var palette := Color("a873ec")
## Decorative frame and matching source symbols; the physical barrier stays unchanged.
@export var frame_texture: Texture2D
@export var seal_icons: Array[Texture2D] = []
var active := false
var opening := 0.0
var clock := 0.0
var _external_power := false
var _lit: Array[bool] = []
var _shape: CollisionShape2D
var _flash := 0.0
const SWITCHES = preload("res://assets/world_expansion/switches.png")

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	z_index = 1
	_shape = CollisionShape2D.new()
	_shape.name = "SealCollision"
	add_child(_shape, false, Node.INTERNAL_MODE_BACK)
	_sync_shape()
	if not Engine.is_editor_hint(): add_to_group("royal_locks")
	queue_redraw()

func _sync_shape() -> void:
	if not is_instance_valid(_shape): return
	var box := RectangleShape2D.new()
	box.size = gate_size
	_shape.shape = box
	_shape.position = Vector2(0, -gate_size.y * 0.5)

func set_powered(value: bool) -> void:
	_external_power = value

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	clock += delta
	_flash = maxf(0.0, _flash - delta)
	var ready := not sources.is_empty()
	var changed := false
	var next_lit: Array[bool] = []
	for path in sources:
		var source := get_node_or_null(path)
		var lit := is_instance_valid(source) and bool(source.get("active"))
		next_lit.append(lit)
		ready = ready and lit
	changed = next_lit != _lit
	_lit = next_lit
	if sources.is_empty(): ready = _external_power
	var next := ready or (latched and active)
	# Non-latching editor variants also avoid closing through the player or a crate.
	if active and not next and _passage_occupied(): next = true
	if next != active:
		active = next
		collision_layer = 0 if active else 1
		_flash = 1.0
		if active:
			var player := get_tree().get_first_node_in_group("player") as Node2D
			if player and player.global_position.distance_to(global_position) < 1600:
				Progress.sfx("checkpoint")
	elif changed:
		_flash = 0.65
	opening = move_toward(opening, 1.0 if active else 0.0, delta * 1.5)
	queue_redraw()

func _passage_occupied() -> bool:
	var area := Rect2(Vector2(-gate_size.x * 0.5 - 42, -gate_size.y - 20), gate_size + Vector2(84, 110))
	for group in ["player", "push_crates"]:
		for body in get_tree().get_nodes_in_group(group):
			if body is Node2D and area.has_point(to_local(body.global_position)): return true
	return false

func _draw() -> void:
	var opacity := 1.0 - opening
	var half := gate_size.x * 0.5
	if frame_texture != null:
		var frame_size := frame_texture.get_size() * (210.0 / frame_texture.get_height())
		draw_texture_rect(frame_texture, Rect2(Vector2(-frame_size.x / 2, -210), frame_size), false)
	if opacity > 0.01:
		draw_rect(Rect2(-half, -gate_size.y, gate_size.x, gate_size.y), Color(palette, 0.13 * opacity))
		for strand in 3:
			var points := PackedVector2Array()
			for step in 25:
				var t := step / 24.0
				points.append(Vector2((strand - 1) * half * 0.61 + sin(t * TAU * 2 + clock * 1.2 + strand) * 5, -gate_size.y * t))
			draw_polyline(points, Color(palette, opacity * 0.18), 12, true)
			draw_polyline(points, Color(palette.lightened(0.3), opacity * 0.84), 3, true)
		for edge in [-1.0, 1.0]:
			draw_line(Vector2(edge * half, 0), Vector2(edge * half, -gate_size.y), Color(palette, opacity * 0.6), 2, true)
	# Painted footplate anchors the magical seal to the surface.
	draw_texture_rect_region(SWITCHES, Rect2(-50, -12, 100, 28), Rect2(724 if active else 0, 640, 362, 202))
	var count := maxi(1, sources.size())
	for i in count:
		var lit := active or (i < _lit.size() and _lit[i])
		var at := Vector2((i - (count - 1) * 0.5) * 37, -112)
		if frame_texture != null: at = Vector2((i - (count - 1) * 0.5) * 36, -132)
		var ink := Color("ffdf78") if lit else Color("6c578a")
		draw_circle(at, 15, Color("27273e"))
		draw_arc(at, 15, 0, TAU, 24, Color("d0b379"), 2, true)
		if i < seal_icons.size() and seal_icons[i] != null:
			draw_texture_rect(seal_icons[i], Rect2(at - Vector2(11, 11), Vector2(22, 22)), false, Color.WHITE if lit else Color(0.40, 0.38, 0.52))
		else:
			draw_colored_polygon(PackedVector2Array([at + Vector2(0, -10), at + Vector2(7, 0), at + Vector2(0, 10), at + Vector2(-7, 0)]), ink)
		if lit: draw_circle(at + Vector2(-2, -3), 2, Color("fff9d1"))
		if _flash > 0:
			draw_arc(at, 16 + (1 - _flash) * 24, 0, TAU, 24, Color(ink, _flash * 0.6), 2, true)

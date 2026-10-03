@tool
extends Node2D
## Stand briefly on the plate to rotate the mirror. Step away before rotating again.
@export var targets: Array[NodePath] = []
@export var receiver_offset := Vector2(620, -175):
	set(value):receiver_offset=value;queue_redraw()
@export var plate_offset := Vector2(-92, 0)
@export var active := false
@export var mirror_texture: Texture2D
@export var mirror_region := Rect2()
@export var receiver_region := Rect2()
@export var mirror_art: Texture2D
@export var receiver_art: Texture2D
const SWITCH = preload("res://assets/world_expansion/switches.png")
var timer := 0.0
var standing := 0.0
var occupied_before := false
var beam_angle := -0.8
var turn_flash := 0.0

func _ready() -> void:
	z_index = -1
	beam_angle = _target_angle()
	queue_redraw()

func _target_angle() -> float:
	return (receiver_offset - Vector2(0, -82)).angle() if active else -1.05

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():return
	timer += delta
	turn_flash = maxf(0, turn_flash - delta)
	var occupied := false
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player != null and player.is_on_floor() and not player.get("frozen"):
		var feet := to_local(player.global_position) - plate_offset
		occupied = absf(feet.x) < 37 and absf(feet.y) < 12
	if occupied:
		standing += delta
		if standing >= 0.35 and not occupied_before:
			occupied_before = true
			set_active(not active)
	else:
		standing = 0
		occupied_before = false
	beam_angle = rotate_toward(beam_angle, _target_angle(), delta * 3.2)
	queue_redraw()

func set_active(value: bool) -> void:
	active = value
	turn_flash = 0.65
	for path in targets:
		var target := get_node_or_null(path)
		if target != null and target.has_method("set_powered"):target.set_powered(active)
	if not Engine.is_editor_hint():Progress.sfx("checkpoint")
	queue_redraw()

func _draw() -> void:
	var source := Vector2(0, -82)
	var distance := source.distance_to(receiver_offset) if active else 185.0
	var finish := source + Vector2.from_angle(beam_angle) * distance
	var glow := Color(1, 0.85, 0.34, 0.12)
	draw_line(source, finish, glow, 17, true)
	draw_line(source, finish, Color(1, 0.94, 0.61, 0.86), 3, true)
	for i in 7:
		var fraction := fposmod(timer * 0.45 + i / 7.0, 1.0)
		draw_circle(source.lerp(finish, fraction), 2.5, Color(1, 0.98, 0.82, 0.8))
	draw_texture_rect_region(SWITCH, Rect2(plate_offset + Vector2(-42, -13), Vector2(84, 27)), Rect2(724 if active else 0, 640, 362, 202))
	if mirror_art != null:
		var size := mirror_art.get_size() * (122.0 / mirror_art.get_height())
		draw_texture_rect(mirror_art, Rect2(Vector2(-size.x / 2, -122), size), false)
	elif mirror_texture != null and mirror_region.has_area():
		var size := mirror_region.size * (122.0 / mirror_region.size.y)
		draw_texture_rect_region(mirror_texture, Rect2(Vector2(-size.x / 2, -122), size), mirror_region)
	else:
		draw_texture_rect_region(SWITCH, Rect2(-34, -111, 68, 111), Rect2(0, 322, 240, 307))
	if receiver_art != null:
		var size := receiver_art.get_size() * (102.0 / receiver_art.get_height())
		draw_texture_rect(receiver_art, Rect2(receiver_offset + Vector2(-size.x / 2, -45), size), false, Color.WHITE if active else Color(0.75, 0.77, 0.85))
	elif mirror_texture != null and receiver_region.has_area():
		var size := receiver_region.size * (102.0 / receiver_region.size.y)
		draw_texture_rect_region(mirror_texture, Rect2(receiver_offset + Vector2(-size.x / 2, -45), size), receiver_region)
	else:
		draw_texture_rect_region(SWITCH, Rect2(receiver_offset + Vector2(-28, -42), Vector2(56, 84)), Rect2(1205 if active else 0, 322, 240, 307))
	if active:
		draw_arc(receiver_offset, 26 + sin(timer * 3) * 3, 0, TAU, 28, Color(1, 0.86, 0.31, 0.8), 3, true)
		draw_circle(receiver_offset, 12, Color(1, 0.94, 0.67, 0.22))
	if turn_flash > 0:
		draw_arc(source, 14 + (0.65 - turn_flash) * 45, 0, TAU, 26, Color(1, 0.89, 0.43, turn_flash), 3, true)

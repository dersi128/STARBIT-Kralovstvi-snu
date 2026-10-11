@tool
extends Node2D
## One explicit action per press. Reusable pickups, repairs and lever switches.
@export_enum("pickup", "repair", "activate") var action := "pickup"
@export var item_id := "bridge_gear"
@export var required_item := ""
@export var required_flag := ""
@export var completion_flag := ""
@export var targets: Array[NodePath] = []
@export var picture: Texture2D
@export var picture_height := 110.0
@export var caption := "Sebrat součástku"
@export var locked_caption := "Nejdřív najdi součástku"
@export var duration := 0.8
## Anchors in the source winch image, not hard-coded screen rectangles.
@export var repair_socket_uv := Vector2(0.4965, 0.475)
@export_range(0.1, 0.5, 0.005) var repair_gear_width := 0.24
const FONT = preload("res://assets/ui/fonts/Nunito.ttf")
const GEAR = preload("res://assets/environment/forest/awakening/gear.png")
const LEVER_BASE = preload("res://assets/environment/forest/awakening/lever_base.png")
const LEVER_HANDLE = preload("res://assets/environment/forest/awakening/lever_handle.png")
var used := false
var actor: CharacterBody2D
var focus := false
var clock := 0.0
var progress := 0.0
var finish_glow := 0.0

func _ready() -> void:
	if not Engine.is_editor_hint():add_to_group("story_interactions")
	queue_redraw()

func available_for(player: CharacterBody2D) -> bool:
	if used or not player.is_on_floor():return false
	var offset := player.global_position - global_position
	if absf(offset.x) > 100.0 or absf(offset.y) > 48.0:return false
	# A nearby item on the other side of a wall is not reachable.
	var from := player.global_position + Vector2(0, -38)
	var ray := PhysicsRayQueryParameters2D.create(from, global_position + Vector2(0, -38), 5, [player.get_rid()])
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func is_unlocked() -> bool:
	var level := get_tree().get_first_node_in_group("level")
	if level == null:return false
	return (required_item.is_empty() or level.inventory.get(required_item, 0) > 0) and (required_flag.is_empty() or level.completed_actions.get(required_flag, false))

func interact(player: CharacterBody2D) -> bool:
	if not available_for(player) or not is_unlocked():return false
	if not player.begin_interaction(self, action, duration):return false
	actor = player
	return true

func repair_stand_x(player: CharacterBody2D) -> float:
	var side := signf(player.global_position.x - global_position.x)
	if is_zero_approx(side):side = -player.facing
	return global_position.x + side * 62.0

func socket_position() -> Vector2:
	if picture == null:return Vector2.ZERO
	var width := picture_height * picture.get_width() / float(picture.get_height())
	return Vector2((repair_socket_uv.x - 0.5) * width, (repair_socket_uv.y - 1.0) * picture_height)

func fitted_gear_size() -> Vector2:
	if picture == null:return Vector2.ZERO
	var width := picture_height * picture.get_width() / float(picture.get_height()) * repair_gear_width
	return Vector2(width, width * GEAR.get_height() / float(GEAR.get_width()))

func complete_interaction(player: CharacterBody2D) -> void:
	if used or actor != player or not is_unlocked():return
	var level := get_tree().get_first_node_in_group("level")
	if action == "pickup":level.inventory[item_id] = int(level.inventory.get(item_id, 0)) + 1
	if not required_item.is_empty():level.inventory[required_item] = int(level.inventory[required_item]) - 1
	if not completion_flag.is_empty():level.completed_actions[completion_flag] = true
	used = true
	actor = null
	progress = 0.0
	finish_glow = 1.0
	for path in targets:
		var target := get_node_or_null(path)
		if target != null and target.has_method("set_powered"):target.set_powered(true)
	Progress.sfx("gold" if action == "pickup" else "repair")
	queue_redraw()

func _physics_process(delta: float) -> void:
	clock += delta
	finish_glow = maxf(0.0, finish_glow - delta)
	if not Engine.is_editor_hint():
		var player := get_tree().get_first_node_in_group("player")
		focus = player != null and player.interaction_candidate == self
		if is_instance_valid(actor) and actor.interaction_target == self:
			progress = clampf(actor.interaction_clock / duration, 0.0, 1.0)
		else:
			actor = null
			progress = 0.0
	queue_redraw()

func _draw() -> void:
	if picture == null:return
	if used and action == "pickup":return
	var width := picture_height * picture.get_width() / float(picture.get_height())
	var bob := sin(clock * 2.5) * 3.0 if action == "pickup" else 0.0
	var center := Vector2(0, -picture_height * 0.5 + bob)
	if focus or finish_glow > 0:
		draw_circle(center, picture_height * 0.58, Color(0.55, 1.0, 0.76, 0.10 + finish_glow * 0.10))
	if action == "activate":
		var ratio := picture_height / LEVER_BASE.get_height()
		var rect := Rect2(-width * 0.5, -picture_height, width, picture_height)
		var pivot := rect.position + Vector2(132, 183) * ratio
		var turn := -1.3 if used else 0.0
		if is_instance_valid(actor):turn = -1.3 * smoothstep(0.25, 0.85, progress)
		draw_texture_rect(LEVER_BASE, rect, false)
		draw_set_transform(pivot, turn)
		draw_texture_rect(LEVER_HANDLE, Rect2(rect.position - pivot, rect.size), false)
	else:
		draw_set_transform(Vector2(0, bob))
		draw_texture_rect(picture, Rect2(-width * 0.5, -picture_height, width, picture_height), false)
	draw_set_transform(Vector2.ZERO)
	if action == "repair":_draw_repair()
	if progress > 0:
		draw_rect(Rect2(-42, -picture_height - 17, 84, 7), Color("234755"))
		draw_rect(Rect2(-42, -picture_height - 17, 84 * progress, 7), Color("9cf3cc"))
	if focus and not used:
		var key := "Akce" if DisplayServer.is_touchscreen_available() else "E"
		var text := key + " · " + caption if is_unlocked() else locked_caption
		var size := FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
		var box := Rect2(-size.x * 0.5 - 12, -picture_height - 58, size.x + 24, 32)
		draw_style_box(_prompt_style(), box)
		draw_string(FONT, box.position + Vector2(12, 23), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("fff8de"))

func _draw_repair() -> void:
	if not used and (not is_instance_valid(actor) or progress < 0.18):return
	var socket := socket_position()
	var fitted := fitted_gear_size()
	# A spindle closes the empty centre; the toothed rim sits inside the brass ring.
	draw_circle(socket, fitted.x * 0.27, Color("54371c"))
	draw_circle(socket, fitted.x * 0.20, Color("d4a54b"))
	var center := socket
	var size := fitted
	var rotation := 0.0
	var opacity := 1.0
	if not used:
		var insert := smoothstep(0.34, 0.82, progress)
		var hand := to_local(actor.global_position) + Vector2(actor.facing * 27, -44)
		center = hand.lerp(socket, insert) + Vector2(0, -sin(insert * PI) * 10)
		size = (fitted * 1.15).lerp(fitted, insert)
		rotation = -actor.facing * 0.35 * (1.0 - insert)
		opacity = smoothstep(0.18, 0.28, progress)
	draw_set_transform(center, rotation)
	draw_texture_rect(GEAR, Rect2(-size * 0.5, size), false, Color(1, 1, 1, opacity))
	draw_set_transform(Vector2.ZERO)
	if used or progress >= 0.82:
		draw_circle(socket, fitted.x * 0.105, Color("ffe0a0"))
		draw_line(socket + Vector2(-1.5, 1.5), socket + Vector2(1.5, -1.5), Color("795029"), 1.5, true)

func _prompt_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("21483e")
	style.set_corner_radius_all(10)
	return style

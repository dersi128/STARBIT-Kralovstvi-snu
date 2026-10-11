@tool
extends Node2D
@export var room_path: NodePath
@export var return_door := false
@export var room_title := "Tajná komnata"
const ARCH = preload("res://assets/shared/pieces/arch.png")
const GEM = preload("res://assets/environment/worldkit/crystal.tres")
const FONT = preload("res://assets/ui/fonts/Nunito.ttf")
var clock := 0.0
var focus := false

func _ready() -> void:
	if not Engine.is_editor_hint(): add_to_group("story_interactions")

func available_for(player: CharacterBody2D) -> bool:
	if not is_visible_in_tree() or not can_process() or not player.is_on_floor(): return false
	var offset := player.global_position - global_position
	return absf(offset.x) < 82 and absf(offset.y) < 40

func interact(player: CharacterBody2D) -> bool:
	if not available_for(player): return false
	var room := get_node_or_null(room_path)
	if room == null: return false
	if return_door: room.leave_room()
	else: room.enter_room(global_position)
	return true

func _physics_process(delta: float) -> void:
	clock += delta
	if not Engine.is_editor_hint():
		var player := get_tree().get_first_node_in_group("player")
		focus = player != null and player.interaction_candidate == self
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2(0, -62), 37, Color(0.08, 0.11, 0.22, 0.9))
	draw_texture_rect(ARCH, Rect2(-48, -126, 96, 128), false, Color("b3cbd0") if not return_door else Color.WHITE)
	draw_texture_rect(GEM, Rect2(-9, -98 + sin(clock * 2) * 2, 18, 24), false, Color(1, 1, 1, 0.55 + sin(clock * 2) * 0.15))
	if focus:
		var key := "Akce" if DisplayServer.is_touchscreen_available() else "E"
		var label := key + (" · Zpět na stezku" if return_door else " · Prozkoumat průchod")
		var size := FONT.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
		draw_style_box(_style(), Rect2(-size.x / 2 - 12, -174, size.x + 24, 34))
		draw_string(FONT, Vector2(-size.x / 2, -150), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("fff4d7"))

func _style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("203c4c")
	style.set_corner_radius_all(10)
	return style

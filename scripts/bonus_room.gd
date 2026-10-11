@tool
extends Node2D
## A separate optional space in the SAME level: pickups and quest state survive.
@export var room_title := "Kořenová skrýš"
@export var room_width := 3400.0
@export var room_spawn := Vector2(180, 550)
@export var challenge_hint := "Načasuj skoky. Pád tě vrátí ke vstupu."
@export_enum("roots", "sky", "castle") var chamber_style := "roots"
const FONT = preload("res://assets/ui/fonts/Nunito.ttf")
const CAVE = preload("res://assets/environment/forest/higgsfield/forest_soil.png")
const WALL = preload("res://assets/environment/castle/castle_wall.png")
var active := false
var visited := false
var return_point := Vector2.ZERO
var saved_checkpoint := Vector2.ZERO
var saved_health := 3
var saved_safe := Vector2.ZERO
var saved_camera := Rect2i()
var paused_nodes: Dictionary = {}
var old_camera: Rect2i
var title_time := 0.0
var notice := ""

func _ready() -> void:
	if Engine.is_editor_hint(): return
	process_physics_priority = -50
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED

func enter_room(from: Vector2) -> void:
	if active: return
	var level := get_parent()
	var player = level.player
	if player.frozen or level.arena_active: return
	return_point = from
	saved_checkpoint = level.checkpoint
	saved_safe = player.last_safe_position
	saved_health = player.health
	var camera := player.get_node("Camera2D") as Camera2D
	saved_camera = Rect2i(camera.limit_left, camera.limit_top, camera.limit_right - camera.limit_left, camera.limit_bottom - camera.limit_top)
	paused_nodes.clear()
	for node in level.get_children():
		if node == self or node == player: continue
		paused_nodes[node] = node.process_mode
		node.process_mode = Node.PROCESS_MODE_DISABLED
	active = true
	visited = true
	level.bonus_active = true
	var game := get_tree().get_first_node_in_group("game")
	if game != null:
		var hint: Node = game.screen.get_node_or_null("TutorialHint")
		if hint != null: hint.queue_free()
	level._set_arena(false)
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	camera.limit_left = 0
	camera.limit_right = int(room_width)
	camera.limit_top = int(global_position.y) - 230
	camera.limit_bottom = int(global_position.y) + 1100
	notice = room_title
	title_time = 3.5
	_reset_player()
	Progress.sfx("checkpoint")

func _reset_player() -> void:
	var player = get_parent().player
	player.cancel_interaction()
	player.global_position = global_position + room_spawn
	player.velocity = Vector2.ZERO
	player.frozen = false
	player.buffer = 0.0
	player.coyote = 0.0
	player.boost_used = false
	player.last_safe_position = player.global_position
	player.invulnerable = 1.0
	player.get_node("Camera2D").reset_follow()
	get_tree().call_group("game", "release_input")

func retry_room() -> void:
	if not active: return
	# Collected gems stay used. Only the timed platform cycle restarts.
	for node in get_children():
		if node.get("countdown") != null:
			node.countdown = -1.0
			node.absent = false
			node.get_node("CollisionShape2D").set_deferred("disabled", false)
		if node.get("origin") != null:
			node.time = 0.0
			node.position = node.origin
	_reset_player()
	notice = "Ještě jeden pokus — diamanty ti zůstávají"
	title_time = 2.5

func leave_room() -> void:
	if not active: return
	var level := get_parent()
	var player = level.player
	active = false
	level.bonus_active = false
	level.checkpoint = saved_checkpoint
	player.health = saved_health
	player.cancel_interaction()
	player.global_position = return_point
	player.last_safe_position = return_point
	player.velocity = Vector2.ZERO
	player.buffer = 0.0
	player.coyote = 0.0
	player.boost_used = false
	player.invulnerable = 1.3
	for node in paused_nodes:
		if is_instance_valid(node): node.process_mode = paused_nodes[node]
	paused_nodes.clear()
	var camera := player.get_node("Camera2D") as Camera2D
	camera.limit_left = saved_camera.position.x
	camera.limit_top = saved_camera.position.y
	camera.limit_right = saved_camera.end.x
	camera.limit_bottom = saved_camera.end.y
	camera.reset_follow()
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().call_group("game", "release_input")

func objective_text() -> String:
	var collected := 0
	var total := 0
	for node in get_children():
		if node.get("kind") == "crystal":
			total += 1
			if node.used: collected += 1
	return "BONUS · %d/%d diamantů · %s" % [collected, total, "Hotovo! Vrať se průchodem." if collected == total else challenge_hint]

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or not active: return
	var player = get_parent().player
	if player.global_position.y > global_position.y + 910 or player.position.x < 0 or player.position.x > room_width:
		retry_room()
	title_time = maxf(0.0, title_time - delta)
	queue_redraw()

func _draw() -> void:
	# The chamber is spatially separated from the main route, with no old geometry behind it.
	draw_rect(Rect2(-800, -900, room_width + 1600, 2200), Color("142a37"))
	if chamber_style == "roots":
		for x in range(-800, int(room_width) + 800, 800):
			draw_texture_rect(CAVE, Rect2(x, -650, 800, 1600), false, Color(0.22, 0.35, 0.39, 0.7))
	elif chamber_style == "castle":
		for x in range(-800, int(room_width) + 800, 450):
			for y in range(-600, 1500, 328):
				draw_texture_rect(WALL, Rect2(x, y, 450, 328), false, Color(0.17, 0.24, 0.35, 0.7))
	else:
		for index in 80:
			var x := fposmod(index * 257.0, room_width + 800) - 400
			var y := fposmod(index * 131.0, 1200) - 250
			draw_circle(Vector2(x, y), 1.0 + index % 3, Color(0.77, 0.85, 1.0, 0.15 + index % 5 * 0.06))
		for index in 12:
			draw_circle(Vector2(index * 370, 750), 210, Color(0.23, 0.35, 0.50, 0.10))
	for index in 12:
		var x := 200.0 + index * room_width / 12.0
		draw_circle(Vector2(x, 690), 120, Color(0.15, 0.58, 0.67, 0.025))
	if title_time > 0 and active:
		var camera := get_viewport().get_camera_2d()
		var center := to_local(camera.get_screen_center_position())
		var size := FONT.get_string_size(notice, HORIZONTAL_ALIGNMENT_LEFT, -1, 26)
		draw_string(FONT, center + Vector2(-size.x / 2, -210), notice, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("fff3cb"))

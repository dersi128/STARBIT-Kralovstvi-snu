@tool
extends "res://scripts/level.gd"
## The two light fountains restore editable groups of flowers and garden scenery.
@export var first_light: NodePath
@export var second_light: NodePath
@export var first_flowers: Array[NodePath] = []
@export var second_flowers: Array[NodePath] = []
@export var first_scenery: Array[NodePath] = []
@export var second_scenery: Array[NodePath] = []
## The conservatory is first seen closed from the sun court. The sun light opens it.
@export var first_gate: NodePath
@export var thorn_gate: NodePath
@export var reward_star: NodePath
@export var ending_friend: NodePath
@export var sun_fountain_texture: Texture2D
@export var moon_fountain_texture: Texture2D
var restored := [false, false]
var growth := [0.0, 0.0]
var light_age := [10.0, 10.0]
var elapsed := 0.0
var ending_spoken := false
const FOUNTAIN_STAND = preload("res://assets/sky_props/wind_core_stand.png")

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return
	var star := get_node_or_null(reward_star)
	if star:
		star.visible = false
		star.process_mode = Node.PROCESS_MODE_DISABLED
	_apply_garden_tints()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	super._physics_process(delta)
	if not is_instance_valid(player): return
	elapsed += delta
	for i in 2:
		var source := get_node_or_null(first_light if i == 0 else second_light)
		if source and bool(source.get("active")) and not restored[i]:
			restored[i] = true
			light_age[i] = 0.0
			for path in first_flowers if i == 0 else second_flowers:
				var bloom := get_node_or_null(path)
				if bloom and bloom.has_method("set_powered"): bloom.set_powered(true)
			Progress.sfx("repair")
		light_age[i] += delta
		growth[i] = move_toward(growth[i], 1.0 if restored[i] else 0.0, delta * 0.48)
	_apply_garden_tints()
	var sun_gate := get_node_or_null(first_gate)
	if sun_gate:
		sun_gate.collision_layer = 0 if restored[0] else 1
		sun_gate.modulate.a = 1.0 - growth[0]
	var complete: bool = restored[0] and restored[1]
	var gate := get_node_or_null(thorn_gate)
	if gate:
		gate.collision_layer = 0 if complete else 1
		gate.modulate.a = maxf(1.0 - growth[0], 1.0 - growth[1]) if complete else 1.0
	var star := get_node_or_null(reward_star)
	if complete and star:
		star.visible = true
		star.process_mode = Node.PROCESS_MODE_INHERIT
	var friend := get_node_or_null(ending_friend)
	if complete and friend and not ending_spoken and player.global_position.distance_to(friend.global_position) < 215:
		var game := get_tree().get_first_node_in_group("game")
		if game and game.get("mode") == "play":
			ending_spoken = true
			game.speak(friend, friend.message, "voice_mole")
	queue_redraw()

func _apply_garden_tints() -> void:
	for i in 2:
		for path in first_scenery if i == 0 else second_scenery:
			var item := get_node_or_null(path) as CanvasItem
			if item:
				if item.has_method("set_growth"):
					item.call("set_growth", growth[i])
				else:
					item.modulate = Color(0.50, 0.44, 0.64).lerp(Color.WHITE, growth[i])

func _draw() -> void:
	super._draw()
	for i in 2:
		var source := get_node_or_null(first_light if i == 0 else second_light)
		if not source: continue
		_draw_fountain(source.position, i)
		if Engine.is_editor_hint(): continue
		var centre: Vector2 = source.position + Vector2(0, -48)
		if light_age[i] < 2.8:
			var age: float = light_age[i]
			draw_arc(centre, 20 + age * 160, 0, TAU, 64, Color(1, 0.88, 0.43, (1.0 - age / 2.8) * 0.75), 4, true)
			for path in first_flowers if i == 0 else second_flowers:
				var flower := get_node_or_null(path) as Node2D
				if not flower: continue
				for mote in 5:
					var t := fposmod(age * 0.6 + mote * 0.17, 1.0)
					var p := centre.lerp(flower.position, t) - Vector2(0, sin(t * PI) * 130)
					draw_circle(p, 4, Color(1, 0.94, 0.52, 0.85 * sin(t * PI)))
	var sun_gate := get_node_or_null(first_gate) as Node2D
	if sun_gate:
		_draw_light_badge(sun_gate.position + Vector2(0, -180), 0)
	var gate := get_node_or_null(thorn_gate) as Node2D
	if gate and not (restored[0] and restored[1]):
		# Two actual light indicators correspond to the two fountains; no persistent text panel.
		for i in 2:
			_draw_light_badge(gate.position + Vector2((i - 0.5) * 52, -180), i)

func _draw_light_badge(at: Vector2, index: int) -> void:
	var light := Color(1, 0.83, 0.3) if index == 0 else Color(0.67, 0.87, 1)
	draw_circle(at, 19, Color(0.21, 0.23, 0.38))
	draw_arc(at, 18, 0, TAU, 32, Color(0.9, 0.78, 0.51), 3, true)
	draw_circle(at, 12, light if restored[index] else Color(0.4, 0.36, 0.49))
	if index == 1:
		draw_circle(at + Vector2(5, -4), 9, Color(0.21, 0.23, 0.38))

func _draw_fountain(at: Vector2, index: int) -> void:
	# The fountain's lowest stone foot meets the unchanged switch/terrace walk line.
	var amount: float = growth[index]
	var stone := Color(0.55, 0.53, 0.68).lerp(Color.WHITE, amount)
	var texture := sun_fountain_texture if index == 0 else moon_fountain_texture
	var art_height := 172.0
	if texture != null:
		art_height = 196.0 * texture.get_height() / maxf(texture.get_width(), 1.0)
		var target := Rect2(at + Vector2(-98, -art_height + 2), Vector2(196, art_height))
		if index == 0:
			# The source sheet's next-row arch tip occupies the empty gap between feet.
			# Keep both feet and every fountain pixel while omitting only that tip.
			var art_scale := 196.0 / texture.get_width()
			for part in [Rect2(0, 0, 388, 353), Rect2(0, 353, 163, 24), Rect2(211, 353, 177, 24)]:
				draw_texture_rect_region(texture, Rect2(target.position + part.position * art_scale, part.size * art_scale), part, stone)
		else:
			draw_texture_rect(texture, target, false, stone)
	else:
		draw_texture_rect_region(FOUNTAIN_STAND, Rect2(at + Vector2(-77, -136), Vector2(154, 136)), Rect2(115, 220, 1025, 905), stone)
	# A small light on the ground identifies the same activation zone as the old crystal.
	var light := Color(1.0, 0.83, 0.34) if index == 0 else Color(0.68, 0.87, 1.0)
	draw_arc(at + Vector2(0, -3), 49, PI + 0.08, TAU - 0.08, 28, Color(light, 0.38 + amount * 0.4), 2.5, true)
	_draw_light_badge(at + Vector2(0, -art_height - 23), index)
	if amount < 0.01: return
	var basin_y := -art_height * 0.375
	# The two painted fountains share animated streams, droplets and basin ripples.
	draw_set_transform(at + Vector2(0, basin_y), 0, Vector2(1, 0.22))
	for ripple in 2:
		var age := fposmod(elapsed * 0.55 + ripple * 0.5, 1.0)
		draw_arc(Vector2.ZERO, 17 + age * 45, 0, TAU, 32, Color(0.8, 0.97, 1, amount * (1.0 - age) * 0.65), 2.3, true)
	draw_set_transform(Vector2.ZERO)
	for side in [-1.0, 1.0]:
		var stream := PackedVector2Array()
		for step in 19:
			var t := step / 18.0
			stream.append(at + Vector2(side * (lerpf(48, 61, t) + sin(t * PI) * 5), lerpf(-art_height * 0.64, basin_y, t)))
		draw_polyline(stream, Color(0.72, 0.95, 1, amount * 0.82), 3.4, true)
		for drop in 5:
			var t := fposmod(elapsed * 0.65 + drop * 0.2, 1.0)
			var point := at + Vector2(side * (lerpf(48, 61, t) + sin(t * PI) * 5), lerpf(-art_height * 0.64, basin_y, t))
			draw_circle(point, 2.8, Color(0.89, 0.99, 1, amount))

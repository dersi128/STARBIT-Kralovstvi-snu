extends Node2D
## Isolated showroom: uses the real Bit controller without changing campaign levels.
const BIOMES := ["forest", "village", "sky", "castle", "garden", "memory", "stars", "heart"]
const TITLES := ["Les a kořeny · 1–2", "Vesnice a strážci · 3–5", "Oblačné ostrovy · 6–8", "Hrad a vězení · 9–10", "Zahrady obrů · 11–15", "Řeka vzpomínek · 16–20", "Hvězdné hory · 21–25", "Temnota a Srdce · 26–30"]
const OLD_BACKGROUNDS := [1, 3, 6, 10]
const NEW_BACKGROUNDS := ["giant_garden", "memory_lakes", "star_mountains", "kingdom_heart"]
const LANDMARKS := ["root_workshop", "cottage", "windmill", "royal_arch", "giant_flower", "mirror_gate", "observatory", "heart_altar"]
var use_hearts := true
var inventory: Dictionary = {}
var completed_actions: Dictionary = {}
var checkpoint := Vector2(110, 560)
var fall_limit := 870.0
var width := 1280.0
var current_biome := 0
var stage: Node2D
var player: CharacterBody2D
var title: Label
var status: Label

func _ready() -> void:
	add_to_group("level")
	for action in ["left", "right", "jump", "interact"]:
		if not InputMap.has_action(action): InputMap.add_action(action)
	for pair in [["left", KEY_A], ["left", KEY_LEFT], ["right", KEY_D], ["right", KEY_RIGHT], ["jump", KEY_SPACE], ["interact", KEY_E]]:
		var event := InputEventKey.new()
		event.physical_keycode = pair[1]
		if not InputMap.action_has_event(pair[0], event): InputMap.action_add_event(pair[0], event)
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.position = Vector2(12, 12)
	panel.size = Vector2(1256, 90)
	panel.color = Color(0.04, 0.10, 0.15, 0.9)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(panel)
	title = Label.new()
	title.position = Vector2(26, 17)
	title.add_theme_font_size_override("font_size", 22)
	layer.add_child(title)
	var help := Label.new()
	help.text = "A/D nebo šipky · pohyb    Mezerník · skok    E · akce    1–8 · prostředí    R · obnovit zkušebnu"
	help.position = Vector2(26, 49)
	layer.add_child(help)
	status = Label.new()
	status.position = Vector2(26, 76)
	status.add_theme_font_size_override("font_size", 14)
	layer.add_child(status)
	build_stage(0)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode >= KEY_1 and event.keycode <= KEY_8:
		build_stage(event.keycode - KEY_1)
	elif event.keycode == KEY_R:
		build_stage(current_biome)

func _process(_delta: float) -> void:
	if is_instance_valid(player):
		status.text = "Životy: %d/3     Součástka: %d     Seber kolečko, oprav mechanismus a aktivuj páku." % [player.health, int(inventory.get("repair_gear", 0))]

func put(scene_path: String, at: Vector2) -> Node2D:
	var object := (load(scene_path) as PackedScene).instantiate() as Node2D
	object.position = at
	stage.add_child(object)
	return object

func build_stage(index: int) -> void:
	if stage != null:
		remove_child(stage)
		stage.queue_free()
	inventory.clear()
	completed_actions.clear()
	current_biome = index
	stage = Node2D.new()
	add_child(stage)
	var background := Node2D.new()
	background.z_index = -20
	stage.add_child(background)
	if index < 4:
		for i in range(4):
			var sprite := Sprite2D.new()
			sprite.texture = load("res://assets/environment/backgrounds/story/level_%02d/part_%d.png" % [OLD_BACKGROUNDS[index], i])
			sprite.region_enabled = true
			sprite.region_rect = Rect2(2, 2, 418, 941)
			sprite.centered = false
			sprite.position = Vector2(i * 418 * 1280.0 / 1672.0, 0)
			sprite.scale = Vector2(1280.0 / 1672.0, 720.0 / 941.0)
			background.add_child(sprite)
	else:
		var sprite := Sprite2D.new()
		sprite.texture = load("res://assets/environment/worlds/backgrounds/" + NEW_BACKGROUNDS[index - 4] + ".png")
		sprite.centered = false
		sprite.scale = Vector2(1280.0 / sprite.texture.get_width(), 720.0 / sprite.texture.get_height())
		background.add_child(sprite)
	var base: String = "res://scenes/world_assets/" + BIOMES[index] + "/"
	var floor_left := put(base + "platform_long.tscn", Vector2(270, 560))
	floor_left.scale = Vector2(1.7, 1.7)
	var floor_right := put(base + "platform_long.tscn", Vector2(1030, 560))
	floor_right.scale = Vector2(1.65, 1.65)
	put(base + "Lift.tscn", Vector2(630, 560))
	put(base + "ledge.tscn", Vector2(830, 335))
	put(base + "crumble_platform.tscn", Vector2(1010, 245))
	var decor := put(base + LANDMARKS[index] + ".tscn", Vector2(1160, 560))
	decor.z_index = -2
	var gate := put(base + "gate.tscn", Vector2(1090, 560))
	gate.name = "Gate"
	var plate := put(base + "pressure_plate.tscn", Vector2(970, 560))
	plate.targets.append(plate.get_path_to(gate))
	var hazard := put(base + "hazard.tscn", Vector2(1230, 560))
	hazard.scale = Vector2(0.65, 0.65)
	put("res://scenes/world_assets/common/gear.tscn", Vector2(210, 560))
	var repair := put(base + "repair_socket.tscn", Vector2(335, 560))
	repair.name = "Repair"
	repair.completion_flag = "showroom_repaired"
	var lever := put("res://scenes/world_assets/common/Lever.tscn", Vector2(415, 560))
	lever.required_flag = "showroom_repaired"
	lever.targets.append(lever.get_path_to(gate))
	player = put("res://scenes/Bit.tscn", checkpoint)
	player.has_fouk = index == 2
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.enabled = false
	camera.set_script(load("res://scripts/world_assets/showcase_camera.gd"))
	player.add_child(camera)
	title.text = "STARBIT · Zkušebna assetů / " + TITLES[index]

func check_portal_contact(_from: Vector2, _to: Vector2) -> bool:
	return false

func respawn_player() -> void:
	player.global_position = checkpoint
	player.velocity = Vector2.ZERO

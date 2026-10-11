extends SceneTree
var failures: Array[String] = []

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func frames(count: int) -> void:
	for i in range(count): await physics_frame

func list_scenes(path: String) -> Array[String]:
	var paths: Array[String] = []
	for file in DirAccess.get_files_at(path):
		if file.ends_with(".tscn"): paths.append(path + "/" + file)
	for folder in DirAccess.get_directories_at(path):
		paths.append_array(list_scenes(path + "/" + folder))
	return paths

func run() -> void:
	# Physics tests run faster than the audio mixer; keep campaign sound effects silent.
	root.get_node("Progress").muted = true
	var scenes := list_scenes("res://scenes/world_assets")
	check(scenes.size() == 171, "Expected 171 asset prefabs")
	for path in scenes:
		var packed := load(path) as PackedScene
		check(packed != null, "Could not load " + path)
		if packed != null:
			var instance := packed.instantiate()
			check(instance != null, "Could not instantiate " + path)
			instance.free()
	var room = load("res://scenes/showcases/WorldAssets.tscn").instantiate()
	root.add_child(room)
	await frames(10)
	for index in range(8):
		room.build_stage(index)
		await frames(12)
		check(room.player.is_on_floor(), "Bit must stand on the platform in biome %d" % index)
		var lift = room.stage.get_node("Lift")
		var deck = lift.get_node("Deck")
		room.player.global_position = deck.global_position + Vector2(0, -2)
		room.player.velocity = Vector2.ZERO
		await frames(12)
		var initial_y: float = room.player.global_position.y
		await frames(48)
		check(room.player.is_on_floor(), "Lift lost its passenger in biome %d" % index)
		check(absf(room.player.global_position.y - deck.global_position.y) < 5, "Lift/feet mismatch in biome %d" % index)
		check(absf(room.player.global_position.y - initial_y) > 25, "Lift did not carry Bit in biome %d" % index)
	room.build_stage(0)
	await frames(12)
	room.player.position = Vector2(195, 560)
	room.player.velocity = Vector2.ZERO
	await frames(4)
	var pickup = room.stage.get_node("Gear")
	check(pickup.interact(room.player), "Pickup should start Bit's interaction")
	await frames(55)
	check(room.inventory.get("repair_gear", 0) == 1, "Gear was not added exactly once")
	room.player.position = Vector2(273, 560)
	await frames(4)
	var repair = room.stage.get_node("Repair")
	check(repair.interact(room.player), "Repair should accept the collected gear")
	await frames(100)
	check(repair.used and room.inventory.get("repair_gear", 0) == 0, "Repair did not consume exactly one gear")
	check(room.completed_actions.get("showroom_repaired", false), "Repair flag missing")
	room.player.position = Vector2(390, 560)
	await frames(4)
	var lever = room.stage.get_node("Lever")
	check(lever.interact(room.player), "Lever should unlock after repair")
	await frames(130)
	var gate = room.stage.get_node("Gate")
	check(gate.powered and gate.position.y < 400, "Lever did not raise the gate")
	var crumble = room.stage.get_node("CrumblePlatform")
	room.player.position = crumble.position + Vector2(0, -2)
	room.player.velocity = Vector2.ZERO
	await frames(80)
	check(crumble.absent and crumble.get_node("Collision").disabled, "Crumble platform must remove collision after warning")
	await frames(220)
	check(not crumble.absent and not crumble.get_node("Collision").disabled, "Crumble platform must return")
	room.player.health = 3
	room.player.invulnerable = 0
	room.player.position = Vector2(1230, 540)
	room.player.velocity = Vector2.ZERO
	await frames(10)
	check(room.player.health < 3, "Hazard should damage Bit")
	room.queue_free()
	await process_frame
	print("WORLD ASSETS: ", scenes.size(), " prefabs; 8 lift/passenger tests; pickup -> repair -> lever -> gate; crumble/return; hazard. Failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)

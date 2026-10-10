extends SceneTree
## Resource migration smoke test. Use an isolated user-data directory.
var failures := 0
var loaded_resources := 0
var game: Node

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func scan(directory: String) -> void:
	for file in DirAccess.get_files_at(directory):
		if file.get_extension() in ["tscn", "tres", "gd", "gdshader"]:
			var path := directory.path_join(file)
			check(ResourceLoader.load(path) != null, "Cannot load " + path)
			loaded_resources += 1
	for child in DirAccess.get_directories_at(directory):
		scan(directory.path_join(child))

func run() -> void:
	# Prevent an unresolved threaded load from leaving a CI process hanging.
	create_timer(120.0).timeout.connect(func():
		push_error("Repository smoke test timed out")
		quit(1)
	)
	for directory in ["assets", "scenes", "levels", "scripts", "shaders", "addons"]:
		scan("res://" + directory)
	var catalog = load("res://addons/starbit_builder/catalog.gd")
	for entry in catalog.ENTRIES:
		check(ResourceLoader.exists(entry.scene), "Missing catalog scene " + entry.id)
		if entry.thumb.begins_with("res://"):
			check(ResourceLoader.exists(entry.thumb), "Missing catalog thumbnail " + entry.id)
	# Dynamic lookup must survive the folder moves too.
	for key in DreamArt.rects:
		check(DreamArt.texture(key) != null, "Missing dynamic art " + key)
	var progress = root.get_node("Progress")
	progress.muted = true
	game = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	for track in ["menu_adventure", "adventure", "boss", "victory"]:
		check(load("res://assets/audio/music/" + track + ".ogg") != null, "Missing music " + track)
	for n in range(1, 11):
		await game.start_level(n)
		check(game.mode == "play", "Level %d failed to start" % n)
		if game.mode != "play":
			continue
		var level = game.level
		var player = level.player
		check(is_instance_valid(player), "Missing Bit in level %d" % n)
		check(player.sheet_frames != null, "Missing Bit animation in level %d" % n)
		check(player.position.distance_to(level.spawn) < 20.0, "Spawn changed in level %d" % n)
		check(game.total_crystals > 0, "No collectibles in level %d" % n)
		var checkpoints := 0
		var goals := 0
		for object in get_nodes_in_group("objects"):
			if not level.is_ancestor_of(object):
				continue
			if object.kind == "checkpoint": checkpoints += 1
			if object.kind == "goal": goals += 1
		check(checkpoints > 0, "Missing checkpoint in level %d" % n)
		check(goals == 1, "Invalid gate count in level %d" % n)
		for enemy in get_nodes_in_group("enemies"):
			if level.is_ancestor_of(enemy):
				check(enemy.anim != null and enemy.anim.sprite_frames != null, "Missing enemy animation in level %d" % n)
		print("LEVEL ", n, " loaded; crystals=", game.total_crystals, " checkpoints=", checkpoints, " gates=", goals)
		level.process_mode = Node.PROCESS_MODE_DISABLED
	game.queue_free()
	await process_frame
	DreamArt.cache.clear()
	await process_frame
	print("RESOURCE CHECK: ", loaded_resources, " resources; failures=", failures)
	quit(1 if failures > 0 else 0)

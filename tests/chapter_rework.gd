extends SceneTree
var failures := 0
var checks := 0
var game: Node
var output := ""

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func frames(count: int) -> void:
	for i in count:
		if is_instance_valid(game) and game.mode == "dialogue" and is_instance_valid(game.mole_dialogue):
			if not game.mole_dialogue.get_meta("test_confirmed", false):
				game.mole_dialogue.set_meta("test_confirmed", true)
				game.mole_dialogue.finished.emit()
		await physics_frame

func run() -> void:
	output = OS.get_environment("STARBIT_TEST_OUTPUT")
	if output.is_empty():
		push_error("Set STARBIT_TEST_OUTPUT to an isolated writable test folder.")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output)
	var progress := root.get_node("Progress")
	progress.save_path = output.path_join("isolated-progress.cfg")
	progress.muted = true
	progress.unlocked = 1
	progress.level_stars.clear()
	game = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await frames(3)
	for n in range(1, 11):
		await game.start_level(n)
		await frames(15)
		var level = game.level
		var player = level.player
		check(level.number == n, "Wrong level number %d" % n)
		check(level.use_hearts, "Inconsistent health rules in %d" % n)
		check(player.has_fouk == (n in [6,7,8]), "Zip appears at the wrong point in %d" % n)
		check(level.has_node("BonusRoom") and level.has_node("SecretEntrance"), "Missing secret room in %d" % n)
		check(player.is_on_floor(), "Spawn has no ground in %d" % n)
		var room = level.get_node("BonusRoom")
		var entrance = level.get_node("SecretEntrance")
		check(not room.active and not room.visible, "Bonus starts active in %d" % n)
		var gems := 0
		for object in get_nodes_in_group("objects"):
			if level.is_ancestor_of(object) and object.kind == "crystal": gems += 1
		check(game.total_crystals == gems, "Bonus gems not included in HUD total %d" % n)
		player.global_position = entrance.global_position + Vector2(0,-3)
		player.velocity = Vector2.ZERO
		await frames(12)
		check(entrance.available_for(player), "Secret door has no reachable standing surface %d" % n)
		var checkpoint: Vector2 = level.checkpoint
		var health: int = player.health
		Input.action_press("interact")
		await frames(1)
		Input.action_release("interact")
		await frames(15)
		check(room.active and level.bonus_active, "E does not enter secret room %d" % n)
		check(player.is_on_floor(), "Bonus spawn has no ground %d" % n)
		var first_gem: Node2D
		for object in room.get_children():
			if object.get("kind") == "crystal": first_gem = object; break
		var count_before: int = game.crystals
		player.global_position = first_gem.global_position + Vector2(0,45)
		player.velocity = Vector2.ZERO
		await frames(6)
		check(first_gem.used and game.crystals == count_before + 1, "Bonus pickup failed %d" % n)
		var remembered: int = game.crystals
		room.retry_room()
		await frames(8)
		check(game.crystals == remembered and first_gem.used, "Retry duplicates or loses bonus gems %d" % n)
		game.pause_game()
		var stopped: Vector2 = player.global_position
		await frames(12)
		check(player.global_position == stopped, "Bonus moves while paused %d" % n)
		game.resume()
		room.leave_room()
		await frames(8)
		check(not level.bonus_active and not room.active, "Bonus return fails %d" % n)
		check(level.checkpoint == checkpoint and player.health == health, "Bonus altered main checkpoint/health %d" % n)
		check(player.global_position.distance_to(entrance.global_position) < 12, "Return point incorrect %d" % n)
		room.enter_room(entrance.global_position)
		check(game.crystals == remembered and first_gem.used, "Re-entry resets crystals %d" % n)
		player.global_position.y = room.global_position.y + 1000
		await frames(4)
		check(player.global_position.distance_to(room.global_position + room.room_spawn) < 10, "Bonus fall fails to reset %d" % n)
		room.leave_room()
		await frames(5)
		if n > 1:
			for child in level.get_children():
				check(not child is TileMapLayer, "Legacy tile layer remains %d" % n)
			check(not level.can_finish_level(), "Story objectives can be skipped %d" % n)
			for child in level.get_children():
				if not child.get_script() or child.get_script().resource_path != "res://scripts/chapter_action.gd": continue
				player.global_position = child.global_position + Vector2(-64,-3)
				player.velocity = Vector2.ZERO
				await frames(12)
				Input.action_press("interact")
				await frames(3)
				Input.action_release("interact")
				await frames(180)
				check(child.used, "Cannot complete story interaction %d/%s" % [n,child.name])
			if n == 8:
				check(not player.has_fouk and level.get_node("ZipAtGate").visible, "Zip does not stay at the gate")
			if n < 10 and n != 5:
				await frames(3)
				player.position = level.get_node("QuestStar").position + Vector2(0, 48)
				player.velocity = Vector2.ZERO
				await frames(20)
				check(level.star_collected and level.can_finish_level(), "Completed objectives did not enable exit %d" % n)
				player.position = level.get_node("Gate").position + Vector2(-70, -3)
				player.velocity = Vector2.ZERO
				await frames(160)
				check(game.mode == "result", "Actual portal contact did not finish level %d" % n)
			if n == 10:
				level.star_collected = true
				player.global_position = level.get_node("JiskraCage").global_position + Vector2(-65,-3)
				player.velocity = Vector2.ZERO
				await frames(270)
				check(game.mode == "cinematic", "Rescue did not start cinematic")
				check(progress.best_stars(10) > 0, "Rescue not saved before movie")
				if is_instance_valid(game.cinematic_view):
					game.cinematic_view.elapsed = 1.0
					game.cinematic_view.skip()
					await frames(8)
					check(game.mode == "result", "Skipping cinematic does not finish chapter")
		print("CHAPTER ", n, " state checks complete; diamonds=", gems)
	print("CHECKS=", checks, " FAILURES=", failures)
	quit(1 if failures else 0)

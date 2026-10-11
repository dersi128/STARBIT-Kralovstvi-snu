extends "res://tests/chapter_rework.gd"

func run() -> void:
	output = OS.get_environment("STARBIT_TEST_OUTPUT")
	if output.is_empty(): quit(2); return
	var progress := root.get_node("Progress")
	progress.save_path = output.path_join("isolated-regressions.cfg")
	progress.muted = true
	game = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await frames(3)
	await game.start_level(5)
	await frames(15)
	var level = game.level
	var player = level.player
	var bear = level.get_node("Boss")
	check(not player.has_fouk, "Boss must be beatable before meeting Zip")
	# Exercise actual top contact with an ordinary jump during each recovery.
	for hit in 3:
		bear.position.x = 5760
		bear.state = "rest"
		bear.timer = -1.0
		bear.shockwaves.clear()
		player.global_position = Vector2(5570, 546)
		player.velocity = Vector2.ZERO
		player.invulnerable = 0
		await frames(10)
		var hp: int = bear.hp
		Input.action_press("jump")
		Input.action_press("right")
		for tick in 110:
			if player.position.x >= 5740: Input.action_release("right")
			await frames(1)
			if bear.hp < hp: break
		game.release_input()
		check(bear.hp == hp - 1, "Normal jump cannot hit Brucoun during recovery %d" % hit)
		check(player.health == 3, "A successful stomp harms Bit")
	await frames(220)
	check(bear.defeated and bear.dialogue_completed, "Guardian rescue dialogue failed")
	check(player.has_fouk and not level.boss_alive, "Guardian rescue did not introduce Zip")
	check(bear.star_released, "Guardian did not release the gate star")

	await game.start_level(10)
	await frames(15)
	level = game.level
	game.enter_portal()
	check(game.mode == "play", "Final exit bypasses the rescue")
	for flag in level.quest_flags: level.completed_actions[flag] = true
	# The actual star is on the approach to Jiskra; collect it through object contact.
	player = level.player
	player.position = level.get_node("QuestStar").position + Vector2(0, 48)
	player.velocity = Vector2.ZERO
	await frames(18)
	check(level.star_collected, "Final key is not collectible before Jiskra")
	player.position = level.get_node("JiskraCage").position + Vector2(-65, -3)
	player.velocity = Vector2.ZERO
	await frames(270)
	check(game.mode == "cinematic", "Final rescue did not enter cinematic")
	if is_instance_valid(game.cinematic_view):
		var movie = game.cinematic_view
		movie.toggle_pause()
		var stopped: float = movie.elapsed
		await frames(60)
		check(is_equal_approx(movie.elapsed, stopped), "Paused movie kept advancing")
		movie.toggle_pause()
		await frames(2250)
		check(game.mode == "result", "Natural movie ending did not finish the chapter")
		check(progress.best_stars(10) > 0, "Chapter completion was not retained")
	print("REGRESSION CHECKS=", checks, " FAILURES=", failures)
	quit(1 if failures else 0)

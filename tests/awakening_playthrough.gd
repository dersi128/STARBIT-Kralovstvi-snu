extends SceneTree
## Runs the authored route with movement/jump/action input, then fault-injects retries.
## Run with a disposable XDG_DATA_HOME to keep the player's save untouched.
var failures := 0
var game: Node
var level: Node2D
var player: CharacterBody2D
var ticks := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func step(count: int = 1) -> void:
	for i in count:
		await physics_frame
		ticks += 1
		if ticks > 16000:
			push_error("Playthrough exceeded its frame budget")
			quit(1)
			return

func walk_to(x: float, budget: int = 500) -> void:
	var direction := signf(x - player.position.x)
	Input.action_press("right" if direction > 0 else "left")
	for i in budget:
		if game.mode == "result" or (x - player.position.x) * direction <= 2.0:break
		await step()
	Input.action_release("right")
	Input.action_release("left")
	await step(8)
	check(game.mode == "result" or absf(player.position.x - x) < 30.0, "Could not walk to x=%s (at %s)" % [x, player.position])

func jump_to(x: float, budget: int = 180) -> void:
	Input.action_press("jump")
	await step(2)
	var direction := signf(x - player.position.x)
	Input.action_press("right" if direction > 0 else "left")
	for i in budget:
		if (x - player.position.x) * direction <= 2.0:
			Input.action_release("right")
			Input.action_release("left")
		if i > 8 and player.is_on_floor():break
		await step()
	Input.action_release("jump")
	Input.action_release("right")
	Input.action_release("left")
	await step(10)
	print("LAND ", player.position)
	check(absf(player.position.x - x) < 40.0, "Jump missed x=%s (at %s)" % [x, player.position])

func use_action(expected: String) -> void:
	await step(3)
	Input.action_press("interact")
	await step(2)
	Input.action_release("interact")
	check(player.interaction_kind == expected, "Action did not start: " + expected)
	for i in 180:
		if player.interaction_kind.is_empty():break
		await step()
	await step(3)

func run() -> void:
	root.get_node("Progress").muted = true
	game = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await game.start_level(1)
	level = game.level
	player = level.player
	level.get_node("Krtecek").set_meta("story_read", true)
	await step(5)
	if game.mode == "dialogue":
		game.mole_dialogue.finished.emit()
		await step(5)
	check(game.mode == "play", "First level failed to enter play")
	check(game.screen.has_node("AdventureHUD") and not game.screen.has_node("CollectibleHUD"), "Old HUD overlaps the adventure strip")
	check(game.hud.hearts.size() == 3 and game.hud._health == 3, "Initial health is not represented in HUD")
	check(not level.get_node("Winch").is_unlocked() and not level.get_node("Lever").is_unlocked(), "Puzzle can be bypassed without gear/repair")
	check(not player.has_fouk, "ZIP must not grant a double jump in level 1")
	await walk_to(780)
	await jump_to(1080)
	await walk_to(1190)
	await jump_to(1500)
	await walk_to(2000)
	# Push the crate close enough to use it as a step to the 195px shelf.
	Input.action_press("right")
	for i in 160:
		if level.get_node("PuzzleCrate").position.x > 2220:break
		await step()
	Input.action_release("right")
	await step(8)
	var crate_x: float = level.get_node("PuzzleCrate").position.x
	check(crate_x > 2200, "Crate did not move")
	await jump_to(crate_x)
	check(player.position.y < 490, "Could not stand on crate")
	await jump_to(2380)
	check(player.position.y < 365, "Gear shelf is not reachable with a normal jump and crate")
	await use_action("pickup")
	check(level.inventory.get("bridge_gear", 0) == 1, "Gear missing from inventory")
	check(game.hud._gear_state == 1 and game.hud.gear_icon.modulate == Color.WHITE, "Collected gear did not light up in inventory")
	check(game.hud._count == game.crystals, "Crystal HUD is stale")
	# A completed pickup must survive all three mistakes without duplication.
	var deaths_before: int = player.deaths
	for i in 3:player.hurt(true)
	check(player.deaths == deaths_before + 1 and player.health == 3, "Three mistakes must refill at checkpoint")
	check(level.inventory.get("bridge_gear", 0) == 1 and level.get_node("Gear").used, "Pickup lost or duplicated on retry")
	await step(10)
	# Cross the crate by jumping; walking through it would push it instead.
	await walk_to(2110)
	await jump_to(2400)
	await walk_to(2788)
	Input.action_press("interact")
	await step(20)
	Input.action_release("interact")
	check(player.interaction_kind == "repair", "Repair did not start for cancellation test")
	var repair_time: float = player.interaction_clock
	game.pause_game()
	await step(20)
	check(is_equal_approx(player.interaction_clock, repair_time), "Paused repair kept advancing")
	game.resume()
	player.hurt(true)
	await step(12)
	check(not player.frozen and player.interaction_kind.is_empty(), "Interrupted action left Bit stuck")
	check(level.inventory.get("bridge_gear", 0) == 1 and not level.completed_actions.get("winch_repaired", false), "Interrupted repair consumed the quest item")
	# Reproduce standing in front of the winch, this time approaching from its right.
	await walk_to(2878)
	await use_action("repair")
	check(absf(player.position.x - 2917.0) < 1.0 and player.facing < 0, "Bit did not stand beside the winch for repair")
	check(level.completed_actions.get("winch_repaired", false), "Winch was not repaired")
	check(level.inventory.get("bridge_gear", 0) == 0, "Repair did not consume exactly one gear")
	check(game.hud._gear_state == 2, "Completed repair is not shown in inventory")
	var winch = level.get_node("Winch")
	check(winch.socket_position().distance_to(Vector2(-0.5, -73.5)) < 0.1, "Gear is not centred in the painted socket")
	await walk_to(3008)
	await use_action("activate")
	await step(75)
	check(level.get_node("RepairBridge").deployed, "Lever did not deploy bridge")
	check(not level.get_node("RepairBridge").collider.disabled, "Bridge has no collision")
	# Check pause keeps the puzzle; the bridge and inventory are not reconstructed.
	game.pause_game()
	await step(3)
	game.resume()
	await step(2)
	check(game.hud._gear_state == 2 and game.hud._count == game.crystals, "HUD lost state on resume")
	await walk_to(4200)
	check(level.checkpoint.x == 4035.0, "Bridge checkpoint was not reached")
	player.invulnerable = 0.0
	player.hurt()
	check(player.health == 2, "Contact did not remove one heart")
	game.hud.update_values(game.crystals, level.star_collected, game.total_crystals)
	check(game.hud.hearts[2].texture == game.hud.EMPTY_HEART and game.hud.hearts[1].texture == game.hud.HEART, "Damage did not empty exactly one heart")
	player.hurt()
	check(player.health == 2, "Invulnerability did not stop duplicate damage")
	player.hurt(true)
	check(player.health == 1 and player.position.x > 3900, "A fall did not return to safe ground")
	player.hurt(true)
	check(player.health == 3 and absf(player.position.x - 4035.0) < 1.0, "Empty health did not return to checkpoint")
	check(level.completed_actions.get("winch_repaired", false) and level.get_node("RepairBridge").deployed, "Completed puzzle reset on failure")
	await step(10)
	# Defeat the patrol through its real top-contact test.
	var enemy = level.get_node("FirstCreature")
	enemy.speed = 0.0
	enemy.position.x = 4390
	await walk_to(4255)
	await jump_to(4390)
	await step(35)
	check(not is_instance_valid(enemy) or enemy.defeated, "Stomp did not defeat the first creature")
	await walk_to(4710)
	await jump_to(5040)
	await walk_to(5500)
	await jump_to(5830)
	await walk_to(6100)
	await jump_to(6350)
	await walk_to(6380)
	await step(8)
	check(level.star_collected, "Final star cannot be collected")
	check(game.hud._has_key and game.hud.star_icon.modulate == Color.WHITE, "Collected star is still shown as missing")
	await walk_to(6740)
	await step(6)
	check(game.mode == "result", "Exit did not finish the level")
	check(root.get_node("Progress").unlocked >= 2, "Next level was not unlocked")
	print("AWAKENING PLAYTHROUGH: failures=", failures, " ticks=", ticks)
	game.queue_free()
	game = null
	level = null
	player = null
	await process_frame
	quit(1 if failures else 0)

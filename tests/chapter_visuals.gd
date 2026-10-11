extends "res://tests/chapter_rework.gd"
func run() -> void:
	output=OS.get_environment("STARBIT_TEST_OUTPUT")
	if output.is_empty():quit(2);return
	root.get_node("Progress").save_path=output.path_join("isolated-visuals.cfg")
	root.get_node("Progress").muted=true
	game=load("res://Main.tscn").instantiate();root.add_child(game)
	await frames(3)
	for n in range(1,11):
		await game.start_level(n)
		await frames(15)
		var level=game.level
		var player=level.player
		level.process_mode=Node.PROCESS_MODE_DISABLED
		var entrance=level.get_node("SecretEntrance")
		player.global_position=entrance.global_position+Vector2(-80,0)
		player.get_node("Camera2D").reset_follow()
		await capture("level_%02d_secret.png"%n)
		if n in [3,6,8,9,10]:
			var at:Vector2={3:Vector2(5250,500),6:Vector2(4900,300),8:Vector2(5100,550),9:Vector2(5150,470),10:Vector2(6820,550)}[n]
			player.global_position=at
			player.get_node("Camera2D").reset_follow()
			await capture("level_%02d_story.png"%n)
		level.process_mode=Node.PROCESS_MODE_INHERIT
		level.get_node("BonusRoom").enter_room(entrance.global_position)
		await frames(8)
		player.position=Vector2(1000,-1990)
		player.get_node("Camera2D").reset_follow()
		level.process_mode=Node.PROCESS_MODE_DISABLED
		await capture("level_%02d_bonus.png"%n)
	var movie=load("res://scripts/chapter_cinematic.gd").new()
	game.screen.add_child(movie)
	movie.paused=true
	for time in [2.5,9.0,17.0,26.0,33.0]:
		movie.elapsed=time;movie._update_shot();movie.ink.queue_redraw()
		await capture("cinematic_%02d.png"%int(time))
	print("VISUAL CAPTURES COMPLETE")
	quit()

func capture(filename:String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(filename))

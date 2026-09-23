extends SceneTree
func frames(n:int):
 for i in n:await process_frame
func shot(path:String):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://verification/"+path)
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game);await frames(3)
 root.get_node("Progress").muted=true
 game.selected_region=1;game.selection();await frames(3);await shot("new-selection.png")
 for n in [1,3,5,6,8,10]:
  game.start_level(n);game.level.player.set_physics_process(false)
  await frames(80);await shot("new-background-%02d.png"%n)
 game.start_level(8);game.level.player.set_physics_process(false);game.level.player.position=Vector2(11000,-250)
 game.level.player.get_node("Camera2D").reset_smoothing()
 await frames(80);await shot("new-upper-route.png")
 quit()

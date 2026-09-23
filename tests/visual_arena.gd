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
 game.start_level(1);game.level.player.position=Vector2(3500,550);game.level.star_collected=true
 for o in get_nodes_in_group("objects"):
  if o.kind=="mole":o.message=""
 await frames(65);await shot("portal-centered.png")
 game.start_level(5);game.level.player.position=Vector2(3700,550);game.level.player.invulnerable=99
 await frames(50);await shot("arena-hp.png")
 quit()

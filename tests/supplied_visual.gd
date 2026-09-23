extends SceneTree
func ticks(n:int):
 for i in n:await physics_frame
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game);await process_frame
 root.get_node("Progress").muted=true
 game.start_level(7);await ticks(3)
 var stinko
 for e in get_nodes_in_group("enemies"):
  if e.kind=="stinko":stinko=e;break
 var p=game.level.player
 p.position=stinko.position+Vector2(-85,-5);p.velocity=Vector2.ZERO
 p.get_node("Camera2D").reset_follow()
 await ticks(25);await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://verification/supplied-stinko.png")
 quit()

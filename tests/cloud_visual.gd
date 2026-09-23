extends SceneTree
func ticks(n:int):
 for i in n:await physics_frame
func shot(name:String):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://verification/"+name+".png")
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game);await process_frame
 root.get_node("Progress").muted=true
 for n in [3,6,7,8]:
  game.start_level(n);await ticks(3)
  var p=game.level.player
  for e in get_nodes_in_group("enemies"):e.queue_free()
  var platform:Node2D
  for c in game.level.get_children():
   if c is AnimatableBody2D and (c.travel!=Vector2.ZERO or (n==3 and c.style=="bridge")):
    platform=c;break
  p.position=platform.position+Vector2(platform.width/2,-5);p.velocity=Vector2.ZERO
  p.get_node("Camera2D").reset_follow();await ticks(80)
  await shot("cloud-stage-%02d"%n)
 quit()

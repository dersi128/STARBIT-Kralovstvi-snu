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
 game.start_level(2);await ticks(20)
 await shot("camera-neutral")
 var zone=get_nodes_in_group("camera_zones")[0]
 game.level.player.position=zone.position+Vector2(-20,50);game.level.player.velocity=Vector2.ZERO
 game.level.player.get_node("Camera2D").reset_follow();await ticks(45)
 await shot("camera-ledge-preview")
 game.start_level(10);await ticks(3)
 var e=get_nodes_in_group("enemies")[0]
 game.level.player.position=Vector2(e.position.x-130,e.position.y);game.level.player.velocity=Vector2.ZERO
 game.level.player.get_node("Camera2D").reset_follow();await ticks(5)
 await shot("camera-late-level")
 quit()

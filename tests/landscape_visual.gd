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
 game.start_level(1);await ticks(15);await shot("landscape-start")
 var p=game.level.player;var river=game.level.get_node("RiverBetweenBanks")
 p.position=Vector2(river.position.x-110,river.position.y-270);p.velocity=Vector2.ZERO
 p.get_node("Camera2D").reset_follow();await ticks(80);await shot("landscape-bridge")
 var cave=game.level.get_node("CaveBackdrop")
 var low=game.level.get_node("low_06")
 p.position=low.position+Vector2(80,-10);p.velocity=Vector2.ZERO
 p.get_node("Camera2D").reset_follow();await ticks(40);await shot("landscape-cave")
 quit()

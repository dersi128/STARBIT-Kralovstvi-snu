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
 game.start_level(5)
 var p=game.level.player
 p.position=Vector2(3900,550);p.invulnerable=99
 var b=game.level.get_node("Boss");b.set_physics_process(false)
 await frames(50);await shot("v7-bound.png")
 b.hp=0;b.defeated=true;b.state="defeated";b.timer=2;b.free_bear()
 await frames(70);await shot("v7-free.png")
 game.start_level(1);p=game.level.player
 p.position=Vector2(3600,550);game.level.star_collected=true
 await frames(70);await shot("v7-portal.png")
 quit()

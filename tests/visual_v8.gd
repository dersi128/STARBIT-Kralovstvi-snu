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
 game.start_level(1);game.level.player.position=Vector2(3560,550);game.level.star_collected=true
 await frames(90);await shot("v8-gate.png")
 game.start_level(5)
 var b=game.level.get_node("Boss");b.hp=0;b.defeated=true;b.state="defeated";b.timer=1.6
 game.level.player.position=Vector2(3850,550)
 await frames(180);await shot("v8-bear.png")
 game.start_level(1,"res://levels/Level_Template.tscn")
 game.level.player.position=Vector2(510,550);Input.action_press("right")
 await frames(60);await shot("v8-push.png")
 Input.action_release("right");quit()

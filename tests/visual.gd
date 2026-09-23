extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var game=load("res://Main.tscn").instantiate();root.add_child(game)
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/home/user/menu.png")
 game.start_level(1)
 for i in 10:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/home/user/level.png")
 game.start_level(5)
 game.level.player.position=Vector2(3780,550)
 for i in 50:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/home/user/boss.png")
 quit()

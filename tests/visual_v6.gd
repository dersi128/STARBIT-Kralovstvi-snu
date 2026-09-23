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
 game.start_level(1);await frames(120);await shot("v6-mole.png")
 game.start_level(2);game.level.player.position=Vector2(2680,470);game.level.player.invulnerable=20;await frames(50);await shot("v6-stinko.png")
 game.start_level(5);game.level.player.position=Vector2(3850,550);game.level.player.invulnerable=20;await frames(45);await shot("v6-boss.png")
 game.start_level(1,"res://levels/Level_Template.tscn");await frames(50);await shot("v6-template.png")
 game.start_level(1);game.level.player.position=Vector2(3500,550);game.level.star_collected=true;await frames(50);await shot("v6-gate.png")
 quit()

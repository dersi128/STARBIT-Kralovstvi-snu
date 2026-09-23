extends SceneTree
var fails:=0
func check(ok:bool,label:String):
 print("PASS " if ok else "FAIL ",label)
 if not ok:fails+=1
func frames(n:int):
 for i in n:await process_frame
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game)
 await frames(30)
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/home/user/menu-v2.png")
 game.selection();await frames(3)
 for b in game.screen.find_children("*","Button",true,false):
  check(b.get_global_rect().end.x<=1280,"level selector fits screen")
 game.settings();await frames(2)
 game.credits();await frames(2)
 game.menu();await frames(2)
 game.start_level(1);await frames(30)
 check(game.bubble.visible,"mole proximity opens bubble")
 var count=game.bubble_text.visible_characters
 await frames(90)
 check(game.bubble_text.visible_characters>count,"dialogue types without resetting")
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/home/user/mole-v2.png")
 var p=game.level.player
 check(p.speed==390 and p.jump_speed==650,"movement parameters unchanged")
 p.position.x=850;await frames(30)
 check(not game.bubble.visible,"leaving mole closes bubble")
 game.pause_game()
 check(root.get_node("Progress").tones.is_empty(),"pause silences all voices")
 root.get_node("Progress").muted=true
 root.get_node("Progress").sfx("voice_mole")
 check(root.get_node("Progress").tones.is_empty(),"mute suppresses dialogue effects")
 root.get_node("Progress").muted=false
 print("PRESENTATION FAILURES ",fails)
 quit(fails)

extends SceneTree
var failures:=0
func check(value:bool,label:String):
 print("PASS " if value else "FAIL ",label)
 if not value:failures+=1
func frames(n:int):
 for i in n:await physics_frame
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game);await frames(2)
 root.get_node("Progress").muted=true
 game.start_level(5);await frames(2)
 var level=game.level
 var boss=level.get_node("Boss")
 var p=level.player
 boss.set_physics_process(false)
 p.set_physics_process(false)
 check(boss.hp==3,"boss starts with exactly three lives")
 check(not level.has_node("GateStar"),"boss star is absent before rescue")
 check(level.get_node("KrtecekArena").kind=="mole","mole replaces Jiskra by arena")
 var gate=level.get_node("goal_19")
 p.position=gate.position;await frames(3)
 check(not gate.gate_open and game.mode=="play","gate locked before rescue and collection")
 p.position=boss.position+Vector2(0,-115);p.previous_bottom=boss.position.y-150;p.velocity.y=100
 boss.state="charge";boss._physics_process(0.01)
 check(boss.hp==3,"boss invulnerable during attack")
 for i in 3:
  p.position=boss.position+Vector2(0,-115);p.previous_bottom=boss.position.y-150;p.velocity.y=100
  boss.state="rest";boss.timer=0;boss._physics_process(0.01)
  check(boss.hp==2-i,"stomp removes one life "+str(i+1))
 check(boss.defeated,"third stomp frees bear")
 p.position=Vector2(3200,550)
 boss.timer=1.6;boss._physics_process(0.01);await frames(65)
 var stars=level.get_children().filter(func(n):return n.get("kind")=="star_key")
 check(stars.size()==1 and not level.boss_alive,"one reward star released")
 check(boss.visible and boss.sprite.modulate.a==1,"freed bear remains visible")
 boss._process(0.01)
 check(boss.healing.get_shader_parameter("freed")==1.0,"purple shadow coloration disappears")
 check(not gate.gate_open,"rescue alone does not unlock gate")
 p.position=stars[0].position;await frames(4)
 check(level.star_collected and gate.gate_open,"collecting reward opens gate")
 check(gate.portal.visible,"portal animation is visible")
 await frames(40)
 check(gate.portal.animation==&"portal","opening transitions to portal loop")
 game.start_level(5);await frames(2)
 check(game.level.get_node("Boss").hp==3 and not game.level.star_collected,"restart resets boss and star")
 game.start_level(1,"res://levels/Level_Template.tscn");await frames(2)
 p=game.level.player;p.set_physics_process(false)
 var camera=p.get_node("Camera2D")
 p.position=Vector2(700,-1100);await frames(90)
 check(camera.get_screen_center_position().y< -700,"camera follows up into sky")
 p.position=Vector2(700,1600);await frames(90)
 check(camera.get_screen_center_position().y>1000,"camera follows down to hiding place")
 check(game.level.fall_limit>1600,"deep custom level is not killed by old fall boundary")
 print("V7 FAILURES ",failures)
 root.get_node("Progress").unlocked=1
 root.get_node("Progress").muted=false
 root.get_node("Progress").save()
 quit(failures)

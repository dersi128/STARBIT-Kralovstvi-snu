extends SceneTree
var failures:=0
func frames(n:int):
 for i in n:await process_frame
func check(ok:bool,msg:String):
 print("PASS " if ok else "FAIL ",msg)
 if not ok:failures+=1
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game);await frames(3)
 root.get_node("Progress").muted=true
 game.start_level(1);await frames(3)
 var level=game.level;var p=level.player
 var gate=get_nodes_in_group("objects").filter(func(o):return o.kind=="goal")[0]
 var guide=level.get_node("mole_8")
 p.position=guide.position-Vector2(50,0);await frames(3);check(guide.narrator.flip_h,"mole faces Bit on left")
 p.position=guide.position+Vector2(50,0);await frames(3);check(not guide.narrator.flip_h,"mole faces Bit on right")
 check(not level.check_portal_contact(gate.position-Vector2(250,0),gate.position+Vector2(250,0)),"locked gate does not transition")
 level.star_collected=true
 check(level.check_portal_contact(gate.position-Vector2(250,0),gate.position+Vector2(250,0)),"fast sweep catches portal")
 check(game.mode=="transition" and p.frozen,"transition immediately freezes player")
 await frames(4);check(game.current==2 and game.mode=="play","next level loads automatically")
 game.start_level(9);await frames(3)
 level=game.level;p=level.player;level.checkpoint=Vector2(2550,1210)
 p.position=Vector2(2550,1450);p.invulnerable=10;await frames(2)
 check(p.deaths==0,"low hideout remains playable")
 p.position=Vector2(2550,1600);await frames(3)
 check(p.deaths==1 and p.position.y<1250,"fall respawns even when invulnerable")
 game.start_level(5);await frames(3)
 level=game.level;p=level.player;var boss=level.get_node("Boss")
 level.checkpoint=Vector2(3100,550);p.position=Vector2(3500,550);await frames(3)
 check(level.arena_active and level.arena_walls[0].collision_layer==1,"arena locks on entry")
 p.position=Vector2(2000,0);await frames(3)
 check(p.position.x>=boss.left-94,"Bit cannot escape left above wall")
 p.position=Vector2(4800,0);await frames(3)
 check(p.position.x<=boss.right+94,"Bit cannot escape right")
 p.hurt(true);await frames(2)
 check(not level.arena_active and boss.hp==3 and p.position.x==3100,"death resets arena at checkpoint")
 boss.set_physics_process(false);p.set_physics_process(false)
 for i in 3:
  p.position=boss.position+Vector2(0,-115);p.previous_bottom=boss.position.y-150;p.velocity.y=100
  boss.state="rest";boss.timer=0;boss._physics_process(0.01);boss._process(0.01)
  if i==0:check(boss.health_label.text=="♥♥♡","heart removed visibly after hit")
 await frames(3);check(not level.arena_active and boss.defeated,"arena opens after third hit")
 game.start_level(10);await frames(3)
 game.level.star_collected=true;gate=get_nodes_in_group("objects").filter(func(o):return o.kind=="goal")[0]
 game.level.check_portal_contact(gate.position,gate.position)
 check(game.mode=="win","last portal finishes game")
 root.get_node("Progress").unlocked=1;root.get_node("Progress").muted=false;root.get_node("Progress").save()
 print("ARENA/PORTAL FAILURES ",failures)
 game.queue_free();await frames(2);quit(failures)

extends SceneTree
var failures:=0
func check(ok:bool,label:String):
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures+=1
func frames(n:int):
 for i in n:await physics_frame
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game);await frames(3)
 root.get_node("Progress").muted=true
 for n in range(1,6):
  game.start_level(n);await frames(2)
  var level=game.level
  check(get_nodes_in_group("objects").all(func(o):return o.kind not in ["screw","gold"]),"diamonds replace all screws level "+str(n))
  if n>1:check(not level.has_node("GateGuide"),"no repeated gate guide level "+str(n))
  var gates=get_nodes_in_group("objects").filter(func(o):return o.kind=="goal")
  check(gates[0].gate_scale==2 and gates[0].gate_flip,"large reversed gate "+str(n))
 game.start_level(1);await frames(2)
 var diamond=get_nodes_in_group("objects").filter(func(o):return o.kind=="crystal" and o.position.x==500)[0]
 game.level.player.position=diamond.position+Vector2(0,49);await frames(20)
 check(game.crystals==1 and diamond.used,"diamond counts once")
 await frames(4);check(game.crystals==1,"diamond cannot duplicate")
 game.start_level(5);await frames(2)
 var boss=game.level.get_node("Boss")
 var p=game.level.player
 boss.set_physics_process(false);p.set_physics_process(false)
 check(boss.hp==3 and boss.get_child_count()==2,"three lives, no added shackles")
 p.position=Vector2(3900,550)
 for i in 3:
  p.position=boss.position+Vector2(0,-115);p.previous_bottom=boss.position.y-150;p.velocity.y=100
  boss.state="rest";boss.timer=0;boss._physics_process(0.01)
 check(boss.defeated,"three stomps free bear")
 boss.timer=2;boss._physics_process(0.01);await frames(65)
 check(boss.healing.get_shader_parameter("freed")==1.0,"purple coloration healed")
 check(boss.wrist_star.visible,"wrist star shines")
 check(game.bubble_name.text=="Brúčoun" and game.speech_content.begins_with("Děkuji"),"bear thanks player in speech bubble")
 check(game.level.get_children().filter(func(n):return n.get("kind")=="star_key").size()==1,"bear throws exactly one star")
 game.start_level(1,"res://levels/Level_Template.tscn");await frames(12)
 p=game.level.player
 var crate=game.level.get_node("PushCrate")
 p.position=Vector2(510,550)
 Input.action_press("right");await frames(85)
 check(crate.position.x>650,"walking pushes crate")
 check(p.pushing and p.sprite.texture.resource_path.contains("push"),"Bit uses pushing pose")
 Input.action_release("right");await frames(3)
 var wall:=StaticBody2D.new();wall.position=Vector2(crate.position.x+65,500)
 var shape:=CollisionShape2D.new();var rect:=RectangleShape2D.new();rect.size=Vector2(20,180);shape.shape=rect;wall.add_child(shape);game.level.add_child(wall)
 Input.action_press("right");await frames(90)
 check(crate.position.x<wall.position.x-46,"wall stops crate without penetration")
 Input.action_release("right");await frames(3)
 p.position=crate.position+Vector2(0,-160);p.velocity=Vector2.ZERO;await frames(40)
 check(p.is_on_floor() and absf(p.position.y-(crate.position.y-76))<4,"Bit can stand on crate")
 var spring=game.level.get_node("SpringPad")
 p.position=spring.position+Vector2(0,-85);p.velocity=Vector2(0,100)
 var launched:=false
 for i in 30:
  await physics_frame
  if p.velocity.y < -700:launched=true
 check(launched,"spring launches Bit")
 game.start_level(1,"res://levels/Level_Template.tscn");await frames(10)
 check(absf(game.level.get_node("PushCrate").position.x-600)<1 and game.crystals==0,"restart resets crate and diamonds")
 root.get_node("Progress").unlocked=1;root.get_node("Progress").muted=false;root.get_node("Progress").save()
 print("V8 FAILURES ",failures)
 game.queue_free();await frames(2);quit(failures)

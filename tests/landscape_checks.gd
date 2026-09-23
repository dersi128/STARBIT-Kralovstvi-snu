extends SceneTree
var failures:=0
func check(ok:bool,message:String):
 print("PASS " if ok else "FAIL ",message)
 if not ok:failures+=1
func ticks(n:int):
 for i in n:await physics_frame
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game);await process_frame
 root.get_node("Progress").muted=true
 for n in range(1,11):
  game.start_level(n);await ticks(3)
  check(not game.level.has_node("Water_0"),"old floating pools removed %d"%n)
  if n<=5:
   check(game.level.has_node("RiverBetweenBanks") and game.level.has_node("RiverBridgeRails"),"bounded river and crossing %d"%n)
   check(game.level.has_node("PushCrateBank") and game.level.has_node("OptionalSpring"),"interactive objects %d"%n)
 game.start_level(1);await ticks(3)
 var p=game.level.player;var bridge=game.level.get_node("BankBridge_7")
 p.position=bridge.position+Vector2(8,-4);p.velocity=Vector2.ZERO
 await ticks(8);check(p.is_on_floor(),"Bit can stand on added bridge")
 Input.action_press("right");await ticks(45);Input.action_release("right")
 check(p.position.x>bridge.position.x+bridge.width and p.deaths==0,"Bit crosses bridge without jump or falling")
 var box=game.level.get_node("PushCrateBank")
 p.position=box.position+Vector2(-62,0);p.velocity=Vector2.ZERO;await ticks(8)
 var bx=box.position.x;Input.action_press("right");await ticks(45);Input.action_release("right")
 check(box.position.x>bx+20,"Bit pushes crate")
 var spring=game.level.get_node("OptionalSpring")
 p.position=spring.position+Vector2(0,-90);p.velocity=Vector2(0,150)
 var launched:=false
 for i in 30:
  await physics_frame
  if p.velocity.y< -700:launched=true
 check(launched,"optional spring launches Bit")
 print("LANDSCAPE FAILURES ",failures);quit(failures)

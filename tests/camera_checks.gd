extends SceneTree
var failures:=0
func check(ok:bool,what:String):
 print("PASS " if ok else "FAIL ",what)
 if not ok:failures+=1
func ticks(n:int):
 for i in n:await physics_frame
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game);await process_frame
 root.get_node("Progress").muted=true
 game.start_level(1);await ticks(5)
 var p=game.level.player;var cam=p.get_node("Camera2D")
 check(absf(cam.global_position.y-(p.global_position.y-60))<10,"neutral camera near Bit")
 var zone=get_nodes_in_group("camera_zones")[0]
 p.global_position=zone.global_position+Vector2(-30,50);p.velocity=Vector2.ZERO
 cam.reset_follow();await ticks(40)
 check(cam.global_position.y>p.global_position.y+30,"ledge previews ground below before jump")
 p.set_physics_process(false);p.global_position=Vector2(5000,0);p.velocity=Vector2(0,850);cam.reset_follow()
 await ticks(40)
 check(cam.global_position.y>p.global_position.y+35,"falling looks down")
 p.velocity=Vector2.ZERO;p.global_position=game.level.spawn;p.set_physics_process(true);await ticks(5);cam.reset_follow();var start=cam.global_position.y
 Input.action_press("jump");await ticks(9);Input.action_release("jump")
 print("JUMP CAMERA ",start," -> ",cam.global_position.y," player ",p.position," floor ",p.is_on_floor());check(absf(cam.global_position.y-start)<8,"small jump keeps vertical view stable")
 game.level.respawn_player();check(cam.global_position.distance_to(p.global_position+Vector2(0,-60))<1,"respawn resets camera immediately")
 game.pause_game();var before=cam.global_position;await ticks(20);check(cam.global_position==before,"camera pauses with level")
 var previous:=0
 for n in range(1,11):
  game.start_level(n);await process_frame
  var count=get_nodes_in_group("enemies").size()
  check(count>=previous,"enemy count progresses in level %d (%d)"%[n,count]);previous=count
  for e in get_nodes_in_group("enemies"):
   var supported:=false
   for platform in game.level.get_children():
    if platform is AnimatableBody2D and absf(platform.position.y-e.position.y)<30:
     if e.origin.x-40>=platform.position.x and e.origin.x+e.patrol+40<=platform.position.x+platform.width:supported=true
   check(supported,"enemy patrol stays on platform")
 print("CAMERA FAILURES ",failures);quit(failures)

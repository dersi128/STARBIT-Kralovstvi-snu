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
 for n in [6,7,8,9,10]:
  game.start_level(n);await ticks(2)
  var movers=[];var water=[]
  for c in game.level.get_children():
   if c is AnimatableBody2D and c.travel!=Vector2.ZERO:movers.append(c)
   if c.get_script()==load("res://scripts/water_feature.gd"):water.append(c)
  check(movers.size()==3,"level %d has 3 moving clouds"%n)
  check(water.size()>0,"level %d has water"%n)
  var cloud=movers[-1];var p=game.level.player
  for e in get_nodes_in_group("enemies"):e.queue_free()
  for c in game.level.get_children():
   if c is AnimatableBody2D and c!=cloud:c.queue_free()
  p.position=cloud.position+Vector2(cloud.width/2,-4);p.velocity=Vector2.ZERO
  await ticks(12)
  var relative=p.position-cloud.position
  var start=cloud.position
  var max_error:=0.0
  var max_travel:=0.0
  for i in 480:
   await physics_frame
   max_travel=maxf(max_travel,cloud.position.distance_to(start))
   max_error=maxf(max_error,absf((p.position-cloud.position).x-relative.x))
  check(p.deaths==0 and p.is_on_floor(),"Bit rides cloud safely in level %d"%n)
  check(max_error<12,"cloud carries Bit without sliding: %d"%n)
  check(max_travel>60,"cloud actually moves")
  var wt=water[0].time;var frozen=cloud.position
  game.pause_game();await ticks(15)
  check(cloud.position==frozen and water[0].time==wt,"pause freezes cloud and water")
  game.resume();await ticks(15);check(cloud.position!=frozen,"resume moves cloud")
 game.start_level(1);await ticks(6)
 var p=game.level.player;var cam=p.get_node("Camera2D")
 cam.reset_follow();var cy=cam.global_position.y
 Input.action_press("jump");await ticks(10);Input.action_release("jump")
 check(absf(cam.global_position.y-cy)<4,"short jump does not bounce camera")
 await ticks(45);Input.action_press("right");await ticks(25);Input.action_release("right");await ticks(8)
 var look=cam.look_x;await ticks(20)
 check(absf(cam.look_x-look)<1,"stopping does not reverse forward view")
 print("CLOUD FAILURES ",failures);quit(failures)

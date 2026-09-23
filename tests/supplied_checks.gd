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
 var counts:=[]
 for n in range(1,11):
  game.start_level(n);await ticks(3)
  var count:=0
  for e in get_nodes_in_group("enemies"):
   if e.kind=="stinko":
    count+=1
    check(e.anim.sprite_frames.resource_path=="res://assets/supplied/stinko.tres","new sheet in level %d"%n)
  counts.append(count)
  check(count==0 if n<7 else count>0,"Stinko introduction level %d"%n)
 print("STINKO COUNTS ",counts)
 game.start_level(7);await ticks(3)
 var stinko
 for e in get_nodes_in_group("enemies"):
  if e.kind=="stinko":stinko=e;break
 check(stinko!=null,"Stinko exists")
 stinko.position.x=stinko.origin.x+stinko.patrol-1;stinko.direction=1
 await ticks(5);check(stinko.direction<0 and stinko.anim.flip_h,"turn and sprite facing left")
 stinko.position.x=stinko.origin.x+1;stinko.direction=-1
 await ticks(5);check(stinko.direction>0 and not stinko.anim.flip_h,"turn and sprite facing right")
 var walk_frame=stinko.anim.frame;await ticks(10)
 check(stinko.anim.animation==&"walk" and stinko.anim.frame!=walk_frame,"walk frames advance")
 var p=game.level.player
 p.position=stinko.position+Vector2(0,-105);p.velocity=Vector2(0,150)
 for i in 30:
  await physics_frame
  if not is_instance_valid(stinko) or stinko.defeated:break
 check(is_instance_valid(stinko) and stinko.defeated,"stomp starts defeat")
 if is_instance_valid(stinko):
  check(stinko.anim.animation in [&"hit",&"defeat"],"hit / defeat animation")
 await ticks(40);check(not is_instance_valid(stinko),"defeat removes enemy")
 game.start_level(7);await ticks(3)
 var reset_count:=0
 for e in get_nodes_in_group("enemies"):
  if e.kind=="stinko":reset_count+=1
 check(reset_count==3,"restart restores Stinko")
 var data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/supplied/pieces.json"))
 var platform_count:=0
 for item in data:
  var scene=load("res://scenes/supplied/"+item.scene+".tscn").instantiate()
  game.level.add_child(scene)
  if item.kind=="platform":
   platform_count+=1
   var shape=scene.get_node("CollisionPolygon2D")
   if shape.polygon.size()<4:check(false,"missing collision "+item.scene)
  scene.queue_free()
 await ticks(2);check(platform_count>30,"all supplied platforms have native collision")
 for name in ["GrassMiddle","SlopeUp","SlopeDown","CloudLong"]:
  game.start_level(1);await ticks(3);p=game.level.player
  var platform=load("res://scenes/supplied/"+name+".tscn").instantiate()
  platform.position=Vector2(700,-500)
  if name=="CloudLong":platform.travel=Vector2(180,-40)
  game.level.add_child(platform)
  p.position=platform.position+Vector2(0,-100);p.velocity=Vector2.ZERO
  await ticks(35)
  check(p.is_on_floor() and p.get_slide_collision_count()>0,"landing on "+name)
  if name=="CloudLong":
   var previous=p.position;await ticks(35)
   check(p.position.x>previous.x+15,"cloud carries Bit")
 print("SUPPLIED FAILURES ",failures);quit(failures)

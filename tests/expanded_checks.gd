extends SceneTree
var failures:=0
func check(ok:bool,msg:String):
 print("PASS " if ok else "FAIL ",msg)
 if not ok:failures+=1
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game);await process_frame
 root.get_node("Progress").muted=true
 for n in range(1,11):
  game.start_level(n);await physics_frame;await process_frame
  var lev=game.level;var p=lev.player
  p.set_physics_process(false)
  var cps=[]
  for o in get_nodes_in_group("objects"):
   if o.kind=="checkpoint":cps.append(o)
  check(cps.size()==2,"level %d: two checkpoints"%n)
  for cp in cps:
   p.position=cp.position;await process_frame;await process_frame
   check(lev.checkpoint==cp.position,"level %d: checkpoint activates"%n)
   p.position.y=lev.fall_limit+100;p.hurt(true);await process_frame
   check(p.position.distance_to(cp.position)<10,"level %d: checkpoint respawn"%n)
  check(lev.get_node("Background").get_child_count()==4,"level %d: four parallax layers"%n)
  if n==10:check(not lev.has_node("Boss"),"courtyard has no boss")
 game.menu();game.selected_region=2;game.selection();await process_frame
 check(game.screen.get_node("LevelCard11").disabled,"future levels are unavailable")
 game.selected_region=0;game.selected_level=1;game.selection();await process_frame
 check(not game.screen.get_node("LevelCard1").disabled,"first level selectable")
 game.start_level(1);await physics_frame
 var original=game.level;var where=original.player.position
 game.pause_game();game.menu();game.resume();await process_frame
 check(game.level==original and game.level.player.position.distance_to(where)<10,"menu/resume preserves level state")
 print("CHECK FAILURES ",failures)
 game.queue_free();await process_frame;quit(failures)

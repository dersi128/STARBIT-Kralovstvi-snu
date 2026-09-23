extends SceneTree
var fails:=0
func check(ok:bool,description:String) -> void:
 print("PASS " if ok else "FAIL ",description)
 if not ok:fails+=1
func frames(n:int) -> void:
 for i in n:await physics_frame
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var game=load("res://Main.tscn").instantiate();root.add_child(game)
 await process_frame
 game.start_level(1);await frames(6)
 check(get_nodes_in_group("enemies").size()==0,"level 1 has no enemies")
 var p=game.level.player
 Input.action_press("right");await frames(10);Input.action_release("right")
 game.pause_game();var pos:Vector2=p.position;await frames(10)
 check(p.position==pos,"pause freezes simulation")
 game.menu();await frames(5);game.resume();check(p.position==pos,"menu / resume keeps exact position")
 root.get_node("Progress").unlocked=4
 game.collect(false);game.collect(true)
 game.start_level(2);await frames(4)
 var enemies=get_nodes_in_group("enemies")
 enemies[0].defeated=true;game.collect(false)
 game.start_level(2);await frames(4)
 check(game.screws==0 and game.gold==0 and not get_nodes_in_group("enemies")[0].defeated,"restart resets collectibles and enemies")
 game.start_level(1);await frames(4)
 check(root.get_node("Progress").unlocked==4,"new game preserves unlocked levels")
 game.start_level(3);await frames(5)
 p=game.level.player
 var cp:Node
 for o in get_nodes_in_group("objects"):
  if o.kind=="checkpoint":cp=o;break
 p.position=cp.position;await frames(3)
 check(cp.used and game.level.checkpoint==cp.position,"checkpoint activation")
 p.position=Vector2(150,900);p.hurt()
 check(p.position.distance_to(cp.position)<10,"respawn uses checkpoint")
 var f:Node
 for o in get_nodes_in_group("objects"):
  if o.kind=="fouk":f=o
 p.position=f.position;await frames(130)
 check(p.has_fouk and f.used and not p.frozen,"Fouk repair completes without screws")
 p.position=Vector2(2850,545);await frames(8)
 Input.action_press("jump");await frames(3);Input.action_release("jump");await frames(3)
 Input.action_press("jump");await frames(2);Input.action_release("jump")
 check(p.boost_used and p.velocity.y<0,"second press activates Fouk")
 await frames(90)
 check(not p.boost_used,"landing restores Fouk")
 game.pause_game();check(root.get_node("Progress").tones.size()==0,"pause stops sound")
 root.get_node("Progress").muted=true;root.get_node("Progress").sound(440);check(root.get_node("Progress").tones.size()==0,"mute suppresses sound")
 root.get_node("Progress").muted=false;root.get_node("Progress").unlocked=1;root.get_node("Progress").save()
 print("STATE FAILURES ",fails)
 game.queue_free();await process_frame
 quit(fails)

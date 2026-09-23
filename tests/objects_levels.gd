extends SceneTree
var failures:=0
func check(ok:bool,label:String):
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures+=1
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game);await process_frame
 game.start_level(6);await process_frame
 var script=load("res://scripts/object.gd")
 for kind in script.KIT_SCENES:
  var obj=Node2D.new();obj.set_script(script);obj.kind=kind;obj.position=Vector2(500,550);game.level.add_child(obj)
  await process_frame
  check(is_instance_valid(obj.kit_instance),"Kind creates "+kind)
  obj.kind="flowers";await process_frame;await process_frame
  check(obj.get_child_count()==1,"Kind replaces previous object "+kind)
  obj.queue_free();await process_frame
 game.start_level(5);await process_frame;game.win()
 check(root.get_node("Progress").unlocked>=6,"level 5 unlocks level 6")
 root.get_node("Progress").unlocked=10;root.get_node("Progress").save()
 var saved=load("res://scripts/progress.gd").new();saved._ready()
 check(saved.unlocked==10,"ten unlocked levels survive loading")
 saved.free()
 game.selection()
 var buttons:Array=[]
 for c in game.screen.get_children():
  if c is GridContainer:
   check(c.get_child_count()==10,"menu has ten cards")
   check(c.columns==5,"menu uses two rows")
 root.get_node("Progress").unlocked=1;root.get_node("Progress").save()
 print("OBJECT/LEVEL FAILURES ",failures)
 game.queue_free();await process_frame;quit(failures)

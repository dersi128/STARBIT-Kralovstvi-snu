extends SceneTree
var fails:=0
func check(ok:bool,text:String):
 print("PASS " if ok else "FAIL ",text)
 if not ok:fails+=1
func frames(n:int):
 for i in n:await physics_frame
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game);await process_frame
 root.get_node("Progress").muted=true
 game.start_level(1);await frames(10)
 check(get_nodes_in_group("enemies").is_empty(),"first level has no enemies")
 var mole=game.level.get_node("mole_8")
 check(mole.narrator.animation=="talk" and mole.narrator.scale.x==0.25,"smaller mole uses talking frames")
 check(game.bubble.visible and not is_instance_valid(game.tip),"only character speech, no bottom tutorials")
 for kind in ["rock_enemy","cloud_enemy","stinko"]:
  var e=load("res://scenes/Enemy_"+kind+".tscn").instantiate();e.position=Vector2(900,550);e.patrol=30;e.speed=65;game.level.add_child(e)
  await frames(35)
  check(e.direction<0 and e.anim.flip_h,"facing matches patrol "+kind)
  check(e.anim.sprite_frames.get_frame_count("walk")==4 and e.anim.animation=="walk","four walking frames "+kind)
  e.defeated=true;await frames(3)
  check(e.anim.animation=="hit","hit frame "+kind)
  await frames(10);check(e.anim.animation=="defeat","defeat frames "+kind)
  await frames(25);check(not is_instance_valid(e),"defeat completes "+kind)
 for n in range(1,6):
  game.start_level(n);await frames(3)
  for e in get_nodes_in_group("enemies"):e.process_mode=Node.PROCESS_MODE_DISABLED
  var level=game.level;var p=level.player;var star=level.get_node_or_null("GateStar")
  if star==null:
   star=load("res://scenes/star_key.tscn").instantiate();star.position=Vector2(4500,455);level.add_child(star)
  var gate:Node
  for o in get_nodes_in_group("objects"):
   if o.kind=="goal":gate=o
  var boss=level.get_node_or_null("Boss")
  if boss:boss.process_mode=Node.PROCESS_MODE_DISABLED
  p.position=gate.position;await frames(3)
  check(game.mode=="play" and not gate.gate_open,"gate locked without star "+str(n))
  p.position=star.position;await frames(3)
  check(level.star_collected and star.used,"star unlock recorded "+str(n))
  if boss:
   p.position=gate.position;await frames(3);check(game.mode=="play","boss also required for final gate")
   boss.defeated=true;level.boss_alive=false
  p.has_fouk=true;p.position=gate.position;await frames(3)
  check(game.mode=="win","gate completes level after star "+str(n))
  game.start_level(n);await frames(3)
  check(not game.level.star_collected and game.crystals==0,"restart resets items "+str(n))
 game.start_level(2);await frames(3)
 check(game.level.get_node("Stinko").kind=="stinko","Stinko placed on level two")
 var p=game.level.player;var crystal=game.level.get_node("DreamCrystal");p.position=crystal.position;await frames(3)
 check(game.crystals==1 and crystal.used,"optional crystal collected once")
 game.start_level(5);await frames(3)
 var boss=game.level.get_node("Boss");boss.process_mode=Node.PROCESS_MODE_DISABLED
 for state in ["warn","charge","rest","hurt","defeated"]:
  boss.state=state;boss._process(0.016)
  check(boss.sprite.animation=={"warn":"warn","charge":"charge","rest":"rest","hurt":"hit","defeated":"hit"}[state],"boss animation "+state)
 game.start_level(1,"res://levels/Level_Template.tscn");await frames(20)
 check(game.level.player.is_on_floor(),"paintable TileMapLayer has working collision")
 check(game.level.title=="Moje stezka","custom template scene is playable")
 game.pause_game();var at:Vector2=game.level.player.position;await frames(5);game.menu();game.resume();await frames(1)
 check(game.level.player.position==at,"menu resumes exact template position")
 print("V6 FAILURES ",fails)
 root.get_node("Progress").unlocked=1;root.get_node("Progress").muted=false;root.get_node("Progress").save()
 quit(fails)

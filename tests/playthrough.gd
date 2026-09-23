extends SceneTree
var game:Node
var failures:=0
func _initialize() -> void:call_deferred("run")
func run() -> void:
 game=load("res://Main.tscn").instantiate();root.add_child(game)
 await process_frame
 for n in range(1,6):
  game.start_level(n)
  await physics_frame
  var p=game.level.player
  var jump_ticks:=0
  var frames:=0
  while game.mode=="play" and frames<6000:
   frames+=1
   if frames%500==0:print("STEP ",n," ",frames," p=",p.position," d=",p.deaths)
   var x:float=p.position.x
   var axis:=1.0
   var want_jump:=false
   var boss=game.level.get_node_or_null("Boss")
   if boss and x>3100 and not boss.defeated:
    if boss.state=="rest":
     var dx:float=boss.position.x-x
     axis=signf(dx) if absf(dx)>10 else 0
     if p.is_on_floor() and absf(dx)<240:want_jump=true
    else:
     # Retreat before charge, stay outside the active arena.
     axis=-1 if x>3150 else 0
   else:
    for c in game.level.get_children():
     if c is AnimatableBody2D:
      if p.is_on_floor() and x>c.position.x+45 and x<c.position.x+c.width and c.position.x+c.width-x<85 and absf(p.position.y-c.position.y)<8:want_jump=true
      if p.is_on_floor() and c.position.x>x and c.position.x-x<115 and c.position.y<p.position.y-25:want_jump=true
    for e in get_nodes_in_group("enemies"):
     if not e.defeated and e.position.x>x and e.position.x-x<145 and absf(e.position.y-p.position.y)<80:want_jump=true
   # Brake in midair above the current ledge, land, then take the next jump.
   if not p.is_on_floor() and p.velocity.y>0 and not boss:
    for c in game.level.get_children():
     if c is AnimatableBody2D and c.width>450 and x>c.position.x and x<c.position.x+c.width-20 and c.position.x+c.width-x<100 and p.position.y<c.position.y-15:axis=0
   if n==3 and not p.has_fouk and x>2770 and x<2850:axis=0
   if not game.level.star_collected and (not boss or boss.defeated):
    var star=game.level.get_node_or_null("GateStar")
    if star and x>star.position.x-100:
     axis=signf(star.position.x-x) if absf(star.position.x-x)>12 else 0.0
     if p.is_on_floor():want_jump=true
   if p.frozen:axis=0
   Input.action_release("left");Input.action_release("right")
   if axis>0:Input.action_press("right")
   elif axis<0:Input.action_press("left")
   if want_jump and jump_ticks<=0:
    Input.action_press("jump");jump_ticks=28
   elif jump_ticks>0:
    jump_ticks-=1
    if jump_ticks==0:Input.action_release("jump")
   await physics_frame
  print("LEVEL ",n," mode=",game.mode," frames=",frames," deaths=",p.deaths," x=",p.position.x," fouk=",p.has_fouk)
  if game.mode!="win":failures+=1
  game.release_input()
 print("FAILURES ",failures)
 quit(failures)

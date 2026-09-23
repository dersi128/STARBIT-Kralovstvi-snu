extends Camera2D
## Quiet follow: persistent forward view, stable short jumps, gentle descent preview.
@export var follow_speed:=6.0
@export var forward_distance:=65.0
@export var fall_lookahead:=70.0
var feet_anchor:=0.0
var look_x:=0.0
var look_y:=0.0
var fall_age:=0.0
var target_player:CharacterBody2D
func _ready() -> void:
 target_player=get_parent() as CharacterBody2D
 top_level=true
 process_physics_priority=10
 position_smoothing_enabled=false
 reset_follow()
func reset_follow() -> void:
 if target_player==null:return
 feet_anchor=target_player.global_position.y
 look_x=0;look_y=0;fall_age=0
 global_position=target_player.global_position+Vector2(0,-60)
 reset_smoothing()
func _physics_process(delta:float) -> void:
 if target_player==null:return
 var p:=target_player.global_position
 if absf(target_player.velocity.x)>80:
  look_x=move_toward(look_x,signf(target_player.velocity.x)*forward_distance,100*delta)
 if target_player.is_on_floor():
  feet_anchor=lerpf(feet_anchor,p.y,1-exp(-5*delta))
 else:feet_anchor=clampf(feet_anchor,p.y-80,p.y+145)
 fall_age=fall_age+delta if target_player.velocity.y>180 else 0.0
 var wanted_y:=fall_lookahead*clampf((fall_age-0.2)/0.6,0,1)
 var zone_x:=0.0
 var priority:=-1000
 for zone in get_tree().get_nodes_in_group("camera_zones"):
  var weight:float=zone.weight_at(p)
  if weight>0 and zone.priority>priority:
   priority=zone.priority
   wanted_y=maxf(wanted_y,zone.look_offset.y*weight)
   zone_x=zone.look_offset.x*weight
 look_y=move_toward(look_y,wanted_y,100*delta)
 var target:=Vector2(p.x+look_x+zone_x,feet_anchor-60+look_y)
 target.y=clampf(target.y,p.y-205,p.y+150)
 global_position.x=lerpf(global_position.x,target.x,1-exp(-follow_speed*delta))
 global_position.y=lerpf(global_position.y,target.y,1-exp(-4.5*delta))

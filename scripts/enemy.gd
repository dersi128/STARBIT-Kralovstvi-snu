@tool
extends Node2D
const SHADOW_BOLT = preload("res://scripts/shadow_bolt.gd")
@export_enum("rock_enemy","cloud_enemy","stinko") var kind := "rock_enemy"
@export var patrol := 240.0
@export var speed := 65.0
## Zaškrtnutím nepřítel vyrazí doleva a jeho trasa povede doleva od výchozí pozice.
@export var obraceni := false:
 set(value):
  obraceni=value
  if is_node_ready():
   direction=-1.0 if obraceni else 1.0
   if is_instance_valid(anim):anim.flip_h=direction<0
   queue_redraw()
@export_group("Stínko – stínové střely")
@export var shadow_bolts_enabled := true
@export_range(200.0, 900.0, 10.0) var shadow_range := 620.0
@export_range(1.0, 8.0, 0.1) var shadow_cooldown := 3.2
@export_range(0.5, 2.0, 0.05) var shadow_warning := 0.85
@export_range(120.0, 400.0, 10.0) var shadow_speed := 230.0
var origin := Vector2.ZERO
var direction := 1.0
var time := 0.0
var defeated := false
var fade := 1.0
var turn_time:=0.0
var anim:AnimatedSprite2D
var attack_cooldown:=0.0
var shadow_wait := 1.2
var shadow_charge := 0.0
var shadow_facing := 1.0
var shadow_seen_deaths := -1
var active_bolt: Node2D
func _ready() -> void:
 direction=-1.0 if obraceni else 1.0
 _setup_sprite()
 if Engine.is_editor_hint(): return
 origin=position
 add_to_group("enemies")
func _physics_process(delta:float) -> void:
 time+=delta
 turn_time=maxf(0,turn_time-delta)
 if Engine.is_editor_hint():queue_redraw();return
 if defeated:
  fade-=delta*2
  _animate()
  if fade<=0:queue_free()
  queue_redraw();return
 if shadow_charge<=0 and not (kind=="stinko" and attack_cooldown>0):_move_patrol(delta)
 var p=get_tree().get_first_node_in_group("player")
 if p and absf(p.global_position.x-global_position.x)<45 and absf(p.global_position.y-(global_position.y-35))<65:
  if p.velocity.y>0 and p.previous_bottom<global_position.y-45:
   defeated=true;p.velocity.y=-440;Progress.sfx("enemy")
  else:
   attack_cooldown=0.5
   p.hurt()
 attack_cooldown=maxf(0,attack_cooldown-delta)
 if not defeated:_update_shadow_attack(delta,p)
 else:shadow_charge=0.0
 _animate()
 queue_redraw()
func _move_patrol(delta:float) -> void:
 var bounds:=_patrol_bounds()
 position.x+=direction*speed*delta
 if position.x>bounds.y:position.x=bounds.y;direction=-1;turn_time=0.18
 if position.x<bounds.x:position.x=bounds.x;direction=1;turn_time=0.18
 position.y=origin.y+(sin(time*2.5)*26 if kind=="cloud_enemy" else (sin(time*2.0)*7.0 if kind=="stinko" else 0.0))

func _patrol_bounds() -> Vector2:
 var distance:=maxf(patrol,0.0)
 return Vector2(origin.x-distance,origin.x) if obraceni else Vector2(origin.x,origin.x+distance)

func _walking_speed() -> float:
 return absf(speed)

func _update_shadow_attack(delta:float,player:Node2D) -> void:
 if kind!="stinko":return
 if not shadow_bolts_enabled or not is_instance_valid(player):
  shadow_charge=0.0
  return
 # Respawning clears an unfinished cast and gives the player time to recover.
 if shadow_seen_deaths>=0 and shadow_seen_deaths!=player.deaths:
  shadow_charge=0.0;shadow_wait=1.2
 shadow_seen_deaths=player.deaths
 if player.frozen or player.invulnerable>0:
  shadow_charge=0.0;shadow_wait=maxf(shadow_wait,0.6)
  return
 shadow_wait=maxf(0.0,shadow_wait-delta)
 if shadow_charge>0:
  shadow_charge=maxf(0.0,shadow_charge-delta)
  if shadow_charge<=0:
   active_bolt=SHADOW_BOLT.new()
   active_bolt.top_level=true
   active_bolt.caster=self
   active_bolt.target=player
   active_bolt.target_deaths=player.deaths
   active_bolt.velocity=Vector2(shadow_facing*shadow_speed,0)
   active_bolt.remaining_distance=shadow_range
   add_child(active_bolt)
   active_bolt.global_position=global_position+Vector2(shadow_facing*36,-48)
   shadow_wait=shadow_cooldown;attack_cooldown=0.4
  return
 if shadow_wait>0 or attack_cooldown>0 or is_instance_valid(active_bolt):return
 var separation:Vector2=player.global_position-global_position
 if absf(separation.x)<140 or absf(separation.x)>shadow_range or absf(separation.y)>80:return
 var aim:=signf(separation.x)
 var from:=global_position+Vector2(aim*36,-48)
 var to:=Vector2(player.global_position.x,from.y)
 var ray:=PhysicsRayQueryParameters2D.create(from,to,5)
 if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():return
 # Lock the direction during the warning; the bolt never tracks a jumping player.
 shadow_facing=aim;direction=aim
 shadow_charge=shadow_warning

func _setup_sprite() -> void:
 anim=get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
 if anim==null:
  anim=AnimatedSprite2D.new();anim.name="AnimatedSprite2D";add_child(anim)
  anim.sprite_frames=load("res://assets/supplied/stinko.tres" if kind=="stinko" else "res://assets/animations/"+kind+".tres")
  anim.scale=Vector2.ONE*0.30;anim.offset=Vector2(0,-168)
 anim.flip_h=direction<0
 if not Engine.is_editor_hint():anim.play("idle")
func _animate() -> void:
 if anim==null:return
 anim.flip_h=direction<0
 anim.speed_scale=1.0
 if defeated:
  anim.play("hit" if fade>0.8 else "defeat")
  anim.modulate.a=minf(1,fade*3)
 elif shadow_charge>0:
  anim.play("warn" if anim.sprite_frames.has_animation("warn") else "attack")
 elif attack_cooldown>0:anim.play("attack")
 elif turn_time>0.10:anim.play("idle")
 elif _walking_speed()<0.1:anim.play("idle")
 else:
  anim.play("walk");anim.speed_scale=clampf(_walking_speed()/65.0,0.5,2.0)
func _draw() -> void:
 if kind!="cloud_enemy" and not defeated:
  draw_set_transform(Vector2(0,1),0,Vector2(1,0.14))
  draw_circle(Vector2.ZERO,26,Color(0.1,0.1,0.25,0.15));draw_set_transform(Vector2.ZERO)
 if kind=="stinko" and shadow_charge>0 and not defeated:
  var charge:=1.0-shadow_charge/maxf(shadow_warning,0.01)
  var center:=Vector2(shadow_facing*36,-48)
  var radius:=5.0+charge*8.0
  draw_circle(center,radius+7,Color(0.53,0.24,0.91,0.18))
  draw_circle(center,radius,Color("934ee0"))
  draw_arc(center,radius+4,-time*4,TAU-time*4,24,Color("ebc5ff"),2,true)
  draw_circle(center,2+charge*3,Color("fff0ff"))
 if Engine.is_editor_hint():
  var end_x:=maxf(patrol,0.0)*(-1.0 if obraceni else 1.0)
  draw_line(Vector2(0,-20),Vector2(end_x,-20),Color.ORANGE,2)

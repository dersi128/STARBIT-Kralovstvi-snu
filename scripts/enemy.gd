@tool
extends Node2D
@export_enum("rock_enemy","cloud_enemy","stinko") var kind := "rock_enemy"
@export var patrol := 240.0
@export var speed := 65.0
var origin := Vector2.ZERO
var direction := 1.0
var time := 0.0
var defeated := false
var fade := 1.0
var turn_time:=0.0
var anim:AnimatedSprite2D
var attack_cooldown:=0.0
func _ready() -> void:
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
 _move_patrol(delta)
 var p=get_tree().get_first_node_in_group("player")
 if p and absf(p.global_position.x-global_position.x)<45 and absf(p.global_position.y-(global_position.y-35))<65:
  if p.velocity.y>0 and p.previous_bottom<global_position.y-45:
   defeated=true;p.velocity.y=-440;Progress.sfx("enemy")
  else:
   attack_cooldown=0.5
   p.hurt()
 attack_cooldown=maxf(0,attack_cooldown-delta)
 _animate()
 queue_redraw()
func _move_patrol(delta:float) -> void:
 position.x+=direction*speed*delta
 if position.x>origin.x+patrol:position.x=origin.x+patrol;direction=-1;turn_time=0.18
 if position.x<origin.x:position.x=origin.x;direction=1;turn_time=0.18
 position.y=origin.y+(sin(time*2.5)*26 if kind=="cloud_enemy" else (sin(time*2.0)*7.0 if kind=="stinko" else 0.0))

func _walking_speed() -> float:
 return absf(speed)

func _setup_sprite() -> void:
 anim=get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
 if anim==null:
  anim=AnimatedSprite2D.new();anim.name="AnimatedSprite2D";add_child(anim)
  anim.sprite_frames=load("res://assets/supplied/stinko.tres" if kind=="stinko" else "res://assets/animations/"+kind+".tres")
  anim.scale=Vector2.ONE*0.30;anim.offset=Vector2(0,-168)
 if not Engine.is_editor_hint():anim.play("idle")
func _animate() -> void:
 if anim==null:return
 anim.flip_h=direction<0
 anim.speed_scale=1.0
 if defeated:
  anim.play("hit" if fade>0.8 else "defeat")
  anim.modulate.a=minf(1,fade*3)
 elif attack_cooldown>0:anim.play("attack")
 elif turn_time>0.10:anim.play("idle")
 elif _walking_speed()<0.1:anim.play("idle")
 else:
  anim.play("walk");anim.speed_scale=clampf(_walking_speed()/65.0,0.5,2.0)
func _draw() -> void:
 if kind!="cloud_enemy" and not defeated:
  draw_set_transform(Vector2(0,1),0,Vector2(1,0.14))
  draw_circle(Vector2.ZERO,26,Color(0.1,0.1,0.25,0.15));draw_set_transform(Vector2.ZERO)
 if Engine.is_editor_hint():draw_line(Vector2(0,-20),Vector2(patrol,-20),Color.ORANGE,2)

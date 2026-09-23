extends CharacterBody2D
@export var speed := 390.0
@export var jump_speed := 650.0
@export var use_new_sheets := true
var sheet_frames:SpriteFrames
var sheet_animation:=""
var sheet_frame:=0
var movement_multiplier:=1.0
var pushing:=false
var push_clock:=0.0
var coyote := 0.0
var buffer := 0.0
var boost_used := false
var facing := 1.0
var anim_time := 0.0
var happy := 0.0
var invulnerable := 0.0
var frozen := false
var has_fouk := false
var previous_bottom := 0.0
var deaths := 0
var sprite: Sprite2D
var drone: Sprite2D
var run_phase:=0.0
var step_clock:=0.0
var land_time:=0.0
var hurt_time:=0.0
var boost_flash:=0.0
const LAND_DURATION:=0.32
const EXTRA_POSES={
 "land":Rect2(696,464,402,250),
 "surprised":Rect2(600,748,250,276)
}
const PICKUP_TEXTURES={
 "crystal":preload("res://assets/worldkit/crystal.tres"),
 "star_key":preload("res://assets/worldkit/star_key.tres")
}
var pose_cache:Dictionary={}
var visual_state:="idle"
var takeoff_time:=0.0
var landing_strength:=0.0
var celebration_age:=1.0
var celebration_duration:=1.2
var celebration_kind:="crystal"
var previous_happy:=0.0
var sparkles:Array[Dictionary]=[]
var pickup_echoes:Array[Dictionary]=[]
func _ready() -> void:
 add_to_group("player")
 collision_layer=2
 collision_mask=5
 sprite=$Visual
 if use_new_sheets and ResourceLoader.exists("res://assets/animations/bit_v2/bit_frames.tres"):
  sheet_frames=load("res://assets/animations/bit_v2/bit_frames.tres")
 drone=Sprite2D.new();add_child(drone)
 DreamArt.set_sprite(drone,"fouk",76)
 for key in EXTRA_POSES:
  var pose:=AtlasTexture.new();pose.atlas=load("res://assets/bit.png");pose.region=EXTRA_POSES[key];pose.filter_clip=true;pose_cache[key]=pose
func _physics_process(delta: float) -> void:
 var previous_position:=global_position
 previous_bottom=global_position.y
 invulnerable=maxf(0,invulnerable-delta)
 happy=maxf(0,happy-delta)
 anim_time+=delta
 land_time=maxf(0,land_time-delta)
 hurt_time=maxf(0,hurt_time-delta)
 boost_flash=maxf(0,boost_flash-delta)
 takeoff_time=maxf(0,takeoff_time-delta)
 if happy>previous_happy+0.01:
  celebration_age=0.0;celebration_duration=happy
 celebration_age+=delta
 previous_happy=happy
 update_visual_effects(delta)
 if frozen:
  velocity=Vector2.ZERO
  animate(delta)
  return
 var axis:=Input.get_axis("left","right")
 movement_multiplier=rain_movement_factor()
 velocity.x=move_toward(velocity.x,axis*speed*movement_multiplier,(3600.0 if axis else 5000.0)*delta)
 if axis: facing=signf(axis)
 if is_on_floor(): coyote=0.12;boost_used=false
 else: coyote-=delta
 if Input.is_action_just_pressed("jump"):
  buffer=0.13
  if coyote<=0 and has_fouk and not boost_used:
   velocity.y=-jump_speed*0.92;boost_used=true;buffer=0;boost_flash=0.3;takeoff_time=0.14;Progress.sfx("boost")
 else: buffer-=delta
 if buffer>0 and coyote>0:
  velocity.y=-jump_speed;coyote=0;buffer=0;takeoff_time=0.14;Progress.sfx("jump")
 if Input.is_action_just_released("jump") and velocity.y< -260: velocity.y=-260
 velocity.y=minf(velocity.y+1450*delta,1000)
 var was_floor:=is_on_floor()
 var falling_speed:=velocity.y
 pushing=false
 move_and_slide()
 if axis and is_on_floor():
  for i in get_slide_collision_count():
   var hit:=get_slide_collision(i)
   var body=hit.get_collider()
   if body is Node and body.is_in_group("push_crates") and absf(hit.get_normal().x)>0.8:
    body.push(axis,delta)
    pushing=true;push_clock+=delta

 if not was_floor and is_on_floor() and falling_speed>140:
  land_time=LAND_DURATION;landing_strength=clampf(falling_speed/1000.0,0.2,1.0);Progress.sfx("land")
 var current_level=get_tree().get_first_node_in_group("level")
 if current_level:
  if current_level.check_portal_contact(previous_position,global_position):return
  if global_position.y>current_level.fall_limit or global_position.x< -150 or global_position.x>current_level.width+150:
   hurt(true)
 animate(delta)

func rain_movement_factor() -> float:
 # Query the actual body position every physics tick, including immediately
 # after a teleport/respawn. The base speed is never overwritten by a trap.
 if get_tree().get_first_node_in_group("rain_clouds")==null:return 1.0
 var body_shape:CollisionShape2D=$Collision
 var query:=PhysicsShapeQueryParameters2D.new()
 query.shape=body_shape.shape
 query.transform=body_shape.global_transform
 query.collision_mask=8
 query.collide_with_areas=true
 query.collide_with_bodies=false
 var factor:=1.0
 for hit in get_world_2d().direct_space_state.intersect_shape(query,32):
  var zone=hit.collider
  if zone is Area2D and zone.is_in_group("rain_clouds") and zone.has_method("movement_factor"):
   # Overlapping rain clouds use the strongest slow, rather than multiplying.
   factor=minf(factor,zone.movement_factor())
 return factor
# These states only transform the Visual sprite. The CharacterBody2D and its
# collision shape retain their original movement and dimensions.
var pose_offsets:Dictionary={}
var visual_stretch:=Vector2.ONE
func animate(delta: float) -> void:
 var key:="idle"
 var height:=98.0
 var stretch:=Vector2.ONE
 var offset:=Vector2.ZERO
 var tilt:=0.0
 var moving:=absf(velocity.x)>20
 var grounded:=is_on_floor()
 var running_phase:=0.0
 visual_state="idle"
 if hurt_time>0:
  key="hurt";visual_state="hurt"
 elif pushing:
  key="push"+str(1+int(push_clock*7)%4);visual_state="push"
  offset.x=facing*9
 elif not grounded:
  if boost_flash>0:
   key="jump";visual_state="boost"
   var power:=sin(clampf(boost_flash/0.3,0,1)*PI)
   stretch=Vector2(1.0-0.065*power,1.0+0.10*power)
  elif takeoff_time>0:
   key="jump";visual_state="takeoff"
   var power:=sin(takeoff_time/0.14*PI)
   stretch=Vector2(1.0-0.055*power,1.0+0.09*power)
  elif velocity.y < -110:
   key="jump";visual_state="rise"
   stretch=Vector2(0.98,1.035)
  elif velocity.y<110:
   key="jump";visual_state="apex"
   stretch=Vector2(1.025,0.985)
  else:
   key="fall";visual_state="fall"
   var fall_amount:=clampf(velocity.y/1000.0,0,1)
   stretch=Vector2(1.0-0.025*fall_amount,1.0+0.045*fall_amount)
  tilt=facing*clampf(velocity.x*facing/speed,0,1)*(-0.035 if visual_state=="fall" else 0.055)
  step_clock=0
 elif moving:
  run_phase+=absf(velocity.x)*delta*0.035
  key="run"+str(1+int(run_phase)%4);visual_state="run"
  running_phase=run_phase*PI*0.5
  offset.y=-absf(sin(running_phase))*1.8
  tilt=facing*(0.025+sin(running_phase)*0.012)
  step_clock+=delta*absf(velocity.x)/speed
  if step_clock>0.23:step_clock=0;Progress.sfx("step")
 else:
  step_clock=0
  stretch=Vector2(1.0-sin(anim_time*3)*0.005,1.0+sin(anim_time*3)*0.008)

 if grounded and hurt_time<=0 and not pushing and land_time>0:
  visual_state="land"
  var t:=1.0-land_time/LAND_DURATION
  var squash:=sin(t*PI)*(0.06+0.11*landing_strength)
  stretch=Vector2(1.0+squash*0.55,1.0-squash)
  offset.y=0.0
  if not moving and t<0.45:
   key="land";height=74.0

 # A running or airborne pickup never replaces the locomotion pose.
 if happy>0 and hurt_time<=0 and not pushing:
  var u:=clampf(celebration_age/maxf(celebration_duration,0.01),0,1)
  var joy:=sin(u*PI)
  tilt+=sin(u*TAU*1.5)*joy*0.055
  if grounded and not moving and land_time<=0:
   visual_state="celebrate"
   if u<0.15:key="surprised";height=90.0
   elif u<0.78:key="happy";height=88.0
   else:key="front"
   var strength:=1.35 if celebration_kind=="star_key" else 1.0
   offset.y=-sin(u*PI)*4.5*strength
   stretch=Vector2(1.0-joy*0.025,1.0+joy*0.04)

 var texture:Texture2D=pose_cache[key] if pose_cache.has(key) else DreamArt.texture(key)
 var sheet_texture:=get_sheet_texture()
 if sheet_texture:
  texture=sheet_texture;height=124.0
  # All new frames share a 384px virtual canvas and a foot pivot at y=356.
  # Do not auto-trim each frame: that would erase the little celebration hop.
  sprite.offset=Vector2(0,-164)
 else:
  if not pose_offsets.has(key):
   var visible_rect:=texture.get_image().get_used_rect()
   pose_offsets[key]=Vector2(texture.get_width()*0.5-visible_rect.get_center().x,texture.get_height()*0.5-visible_rect.end.y)
  sprite.offset=pose_offsets[key]
 sprite.texture=texture
 visual_stretch=visual_stretch.lerp(stretch,1.0-exp(-30.0*delta))
 sprite.scale=Vector2.ONE*(height/texture.get_height())*visual_stretch
 sprite.flip_h=facing<0
 sprite.rotation=lerpf(sprite.rotation,tilt,1.0-exp(-22.0*delta))
 sprite.position=offset
 var warmth:=sin(clampf(celebration_age/maxf(celebration_duration,0.01),0,1)*PI)*0.065 if happy>0 else 0.0
 sprite.modulate=Color(1.0+warmth,1.0+warmth,1.0+warmth)
 sprite.modulate.a=0.4 if invulnerable>0 and int(anim_time*14)%2==0 else 1.0
 drone.visible=has_fouk
 drone.position=Vector2(-facing*40,-100+sin(anim_time*4)*5)
 if boost_used and velocity.y<0:drone.position=Vector2(0,-114)
 drone.rotation=sin(anim_time*4)*0.045
 drone.flip_h=facing<0
 queue_redraw()

func get_sheet_texture() -> Texture2D:
 sheet_animation="";sheet_frame=0
 if not use_new_sheets or sheet_frames==null:return null
 match visual_state:
  "idle":
   sheet_animation="idle";sheet_frame=sheet_frame_at("idle",anim_time,true)
  "run":
   sheet_animation="run";sheet_frame=int(run_phase*1.2)%8
  "takeoff":
   sheet_animation="takeoff";sheet_frame=clampi(int((1.0-takeoff_time/0.14)*4.0),0,3)
  "rise":
   sheet_animation="rise";sheet_frame=clampi(int((velocity.y+jump_speed)/(jump_speed-110.0)*3.0),0,2)
  "apex":
   sheet_animation="rise";sheet_frame=3
  "fall":
   sheet_animation="fall";sheet_frame=clampi(int((velocity.y-110.0)/540.0*4.0),0,3)
  "land":
   if absf(velocity.x)>20:
    sheet_animation="run";sheet_frame=int(run_phase*1.2)%8
   else:
    sheet_animation="land";sheet_frame=clampi(int((1.0-land_time/LAND_DURATION)*4.0),0,3)
  "boost":
   sheet_animation="rise";sheet_frame=clampi(int((1.0-boost_flash/0.3)*4.0),0,3)
  "celebrate":
   sheet_animation="collect_star" if celebration_kind=="star_key" else "collect_diamond"
   var progress:=celebration_age/maxf(celebration_duration,0.01)
   sheet_frame=sheet_frame_at(sheet_animation,progress*sheet_duration(sheet_animation))
 if sheet_animation.is_empty():return null
 return sheet_frames.get_frame_texture(sheet_animation,sheet_frame)

func sheet_duration(animation:String) -> float:
 var units:=0.0
 for i in sheet_frames.get_frame_count(animation):
  units+=sheet_frames.get_frame_duration(animation,i)
 return units/maxf(0.01,sheet_frames.get_animation_speed(animation))

func sheet_frame_at(animation:String,seconds:float,looped:bool=false) -> int:
 var duration:=sheet_duration(animation)
 var time:=fposmod(seconds,duration) if looped else clampf(seconds,0,duration)
 var units:=time*sheet_frames.get_animation_speed(animation)
 var count:=sheet_frames.get_frame_count(animation)
 for i in count:
  var hold:=sheet_frames.get_frame_duration(animation,i)
  if units<hold:return i
  units-=hold
 return maxi(0,count-1)

func celebrate_collect(kind:String,world_origin:Vector2) -> void:
 celebration_kind=kind
 celebration_duration=1.6 if kind=="star_key" else 1.2
 if use_new_sheets and sheet_frames:
  celebration_duration=sheet_duration("collect_star" if kind=="star_key" else "collect_diamond")
 celebration_age=0.0;happy=celebration_duration;previous_happy=happy
 if PICKUP_TEXTURES.has(kind):
  pickup_echoes.append({"kind":kind,"origin":world_origin,"age":0.0})
  if pickup_echoes.size()>4:pickup_echoes.pop_front()
 var count:=14 if kind=="star_key" else 9
 var color:=Color("ffe17a") if kind=="star_key" else Color("a8eaff")
 for i in count:
  var angle:float=-PI+float(i)/count*TAU
  var direction:=Vector2(cos(angle),sin(angle))
  sparkles.append({"position":world_origin+direction*8,"velocity":direction*(36.0+float(i%3)*16.0)+Vector2(0,-24),"age":0.0,"life":0.62+float(i%3)*0.06,"radius":2.5+float(i%3)*0.8,"color":color})
 while sparkles.size()>36:sparkles.pop_front()
 queue_redraw()

func update_visual_effects(delta:float) -> void:
 for i in range(sparkles.size()-1,-1,-1):
  var particle:Dictionary=sparkles[i]
  particle.age+=delta
  particle.position+=particle.velocity*delta
  particle.velocity.y+=65.0*delta
  if particle.age>=particle.life:sparkles.remove_at(i)
 for i in range(pickup_echoes.size()-1,-1,-1):
  pickup_echoes[i].age+=delta
  if pickup_echoes[i].age>=0.42:pickup_echoes.remove_at(i)

func _draw() -> void:
 if is_on_floor():
  draw_set_transform(Vector2(0,1),0,Vector2(1,0.2))
  draw_circle(Vector2.ZERO,19,Color(0.15,0.3,0.32,0.13))
  if land_time>0:
   var t:=1.0-land_time/LAND_DURATION
   draw_arc(Vector2.ZERO,20+t*21,0,TAU,24,Color(0.82,1,0.89,(1-t)*0.32),2,true)
  draw_set_transform(Vector2.ZERO)
 for echo in pickup_echoes:
  var t:float=clampf(echo.age/0.42,0,1)
  var ease:=1.0-pow(1.0-t,3)
  var center:Vector2=to_local(echo.origin).lerp(Vector2(0,-55),ease)+Vector2(0,-sin(t*PI)*22)
  var size:=lerpf(30,8,ease)
  draw_texture_rect(PICKUP_TEXTURES[echo.kind],Rect2(center-Vector2.ONE*size*0.5,Vector2.ONE*size),false,Color(1,1,1,1.0-t))
 for particle in sparkles:
  var t:float=particle.age/particle.life
  var radius:float=particle.radius*sin(minf(1.0,t*5.0)*PI*0.5)*(1.0-t)
  if radius<0.1:continue
  var color:Color=particle.color;color.a=(1.0-t)*0.9
  var center:Vector2=to_local(particle.position)
  var points:=PackedVector2Array()
  for i in 8:
   var angle:float=float(i)*PI/4+particle.age*1.6
   points.append(center+Vector2(cos(angle),sin(angle))*radius*(1.0 if i%2==0 else 0.3))
  draw_colored_polygon(points,color)
 if has_fouk and is_instance_valid(drone):
  var rotor:=drone.position+Vector2(0,-31)
  var span:=27*cos(anim_time*65)
  draw_line(rotor-Vector2(span,0),rotor+Vector2(span,0),Color(0.82,1,1,0.75),3,true)
  if boost_flash>0:
   draw_arc(Vector2(0,-72),30+(0.3-boost_flash)*70,0,TAU,32,Color(0.55,0.9,1,boost_flash*2),3,true)
func hurt(force:bool=false) -> void:
 if not force and (invulnerable>0 or frozen): return
 deaths+=1
 happy=0;previous_happy=0;land_time=0;takeoff_time=0;sparkles.clear();pickup_echoes.clear()
 Progress.sfx("hurt");hurt_time=0.3
 get_tree().call_group("level","respawn_player")
 invulnerable=1.3

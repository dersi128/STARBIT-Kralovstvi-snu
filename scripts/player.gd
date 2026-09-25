extends CharacterBody2D
@export var speed := 390.0
@export var jump_speed := 650.0
@export var use_new_sheets := true
@export_range(0.5,2.0,0.05) var hurt_animation_duration:=0.95
const GROUND_ACCELERATION:=2800.0
const GROUND_BRAKING:=4200.0
const RUN_CYCLE_DISTANCE:=168.0
# Contact -> compression -> passing foot -> extension, twice per stride.
# The source sheet puts extension before passing; playing it in file order
# repeatedly kicks the foot forward before pulling it back.
const RUN_FRAME_ORDER:=[0,1,3,2,4,5,7,6]
const RUN_FRAME_HOLDS:=[1.15,0.9,1.1,0.85,1.15,0.9,1.1,0.85]
const RUN_POSE_HEIGHTS:=[298.0,276.0,296.0,292.0,299.0,279.0,300.0,290.0]
const TAKEOFF_DURATION:=0.10
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
var land_time:=0.0
var hurt_time:=0.0
var boost_flash:=0.0
var air_time:=0.0
var state_age:=0.0
var idle_time:=0.0
var ground_distance:=0.0
var ground_speed:=0.0
var floor_motion_y:=0.0
var floor_visual_offset:=0.0
var acceleration_lean:=0.0
var turn_time:=0.0
var stop_time:=0.0
var pickup_pose_active:=false
const LAND_DURATION:=0.32
const LAND_RUN_RECOVERY:=0.18
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
 floor_snap_length=8.0
 floor_constant_speed=true
 sprite=$Visual
 sprite.position=Vector2.ZERO
 if use_new_sheets and ResourceLoader.exists("res://assets/animations/bit_v2/bit_frames.tres"):
  sheet_frames=load("res://assets/animations/bit_v2/bit_frames.tres")
 drone=Sprite2D.new();add_child(drone)
 DreamArt.set_sprite(drone,"fouk",76)
 for key in EXTRA_POSES:
  var pose:=AtlasTexture.new();pose.atlas=load("res://assets/bit.png");pose.region=EXTRA_POSES[key];pose.filter_clip=true;pose_cache[key]=pose
func _physics_process(delta: float) -> void:
 var previous_position:=global_position
 var previous_speed:=velocity.x
 ground_distance=0.0;ground_speed=0.0
 previous_bottom=global_position.y
 invulnerable=maxf(0,invulnerable-delta)
 happy=maxf(0,happy-delta)
 anim_time+=delta
 land_time=maxf(0,land_time-delta)
 hurt_time=maxf(0,hurt_time-delta)
 boost_flash=maxf(0,boost_flash-delta)
 takeoff_time=maxf(0,takeoff_time-delta)
 turn_time=maxf(0,turn_time-delta)
 stop_time=maxf(0,stop_time-delta)
 air_time=0.0 if is_on_floor() else air_time+delta
 if happy>previous_happy+0.01:
  celebration_age=0.0;celebration_duration=happy
  pickup_pose_active=is_on_floor() and absf(velocity.x)<8
 celebration_age+=delta
 previous_happy=happy
 update_visual_effects(delta)
 if frozen:
  velocity=Vector2.ZERO
  animate(delta)
  return
 # Discard vertical motion left by walking up/down a slope, while keeping
 # impulses applied by a spring, enemy bounce or other game object.
 if is_on_floor() and is_equal_approx(velocity.y,floor_motion_y):velocity.y=0.0
 var axis:=Input.get_axis("left","right")
 movement_multiplier=rain_movement_factor()
 var acceleration:=3600.0 if axis else 5000.0
 if is_on_floor():
  acceleration=GROUND_ACCELERATION if axis else GROUND_BRAKING
  if axis*velocity.x<0:acceleration=3600.0
 velocity.x=move_toward(velocity.x,axis*speed*movement_multiplier,acceleration*delta)
 acceleration_lean=clampf((velocity.x-previous_speed)/maxf(delta*GROUND_ACCELERATION,0.01),-1,1)
 # Finish braking before facing the other way, rather than skating backwards.
 var next_facing:=facing
 if absf(velocity.x)>8:next_facing=signf(velocity.x)
 elif axis:next_facing=signf(axis)
 if next_facing!=facing:turn_time=0.12
 facing=next_facing
 if is_on_floor() and absf(previous_speed)>8 and absf(velocity.x)<=8:stop_time=0.16
 if is_on_floor(): coyote=0.12;boost_used=false
 else: coyote-=delta
 if Input.is_action_just_pressed("jump"):
  buffer=0.13
  if coyote<=0 and has_fouk and not boost_used:
   velocity.y=-jump_speed*0.92;boost_used=true;buffer=0;boost_flash=0.3;begin_jump();Progress.sfx("boost")
 else: buffer-=delta
 if buffer>0 and coyote>0:
  velocity.y=-jump_speed;coyote=0;buffer=0;begin_jump();Progress.sfx("jump")
 if Input.is_action_just_released("jump") and velocity.y< -260: velocity.y=-260
 velocity.y=minf(velocity.y+1450*delta,1000)
 var was_floor:=is_on_floor()
 var falling_speed:=velocity.y
 pushing=false
 move_and_slide()
 floor_motion_y=velocity.y
 floor_visual_offset=0.0
 if is_on_floor():
  # Count actual travel, excluding a moving platform carrying a standing Bit.
  var travel:float=global_position.x-previous_position.x-get_platform_velocity().x*delta
  # Use distance along the surface, so strides match uphill/downhill travel.
  var floor_up:=maxf(-get_floor_normal().y,0.01)
  ground_distance=absf(travel)/floor_up
  ground_speed=ground_distance/maxf(delta,0.001)
  # A rounded foot touches the slope beside its lowest point. Move only the
  # drawing to the surface beneath its centre; collision stays upright.
  var body_shape:Shape2D=$Collision.shape
  if body_shape is CapsuleShape2D:
   floor_visual_offset=body_shape.radius*(1.0/floor_up-1.0)
 if is_on_ceiling():takeoff_time=0.0;boost_flash=0.0
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

func begin_jump() -> void:
 takeoff_time=TAKEOFF_DURATION;air_time=0.0;land_time=0.0;stop_time=0.0
 pickup_pose_active=false

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
# Animation affects only Visual; input and collision geometry are independent
# of the pose, so landing and collecting never delay a jump or a direction change.
var pose_offsets:Dictionary={}
var visual_stretch:=Vector2.ONE
func animate(delta: float) -> void:
 var previous_state:=visual_state
 var key:="idle"
 var height:=98.0
 var stretch:=Vector2.ONE
 var offset:=Vector2.ZERO
 var tilt:=0.0
 var grounded:=is_on_floor()
 var moving:=ground_speed>8.0 if grounded else absf(velocity.x)>8.0
 var speed_ratio:=clampf(ground_speed/maxf(speed,1.0),0.0,1.0)
 var hurt_age:=hurt_animation_duration-hurt_time
 var show_hurt_pose:=hurt_time>0 and (hurt_age<0.18 or (grounded and not moving and not pushing))
 visual_state="idle"

 # One gait cycle is two steps. Slow rain, braking and a blocked wall cannot
 # leave the feet running at full speed; platform motion does not count.
 if grounded and moving and not pushing:
  var next_phase:=run_phase+ground_distance/RUN_CYCLE_DISTANCE
  if int(next_phase*2.0)>int(run_phase*2.0) and not show_hurt_pose:
   Progress.sfx("step")
  run_phase=fposmod(next_phase,1.0)
 elif grounded and not moving:
  run_phase=0.0

 if show_hurt_pose:
  key="hurt";visual_state="hurt";height=86.0
 elif pushing:
  key="push"+str(1+int(push_clock*7)%4);visual_state="push"
  offset.x=facing*9
 elif not grounded:
  if boost_flash>0:
   key="jump";visual_state="boost"
   var power:=sin(clampf(boost_flash/0.3,0,1)*PI)
   stretch=Vector2(1.0-0.045*power,1.0+0.07*power)
  elif takeoff_time>0:
   key="jump";visual_state="takeoff"
   var power:=sin(clampf(takeoff_time/TAKEOFF_DURATION,0,1)*PI)
   stretch=Vector2(1.0-0.04*power,1.0+0.065*power)
  elif velocity.y < -110:
   key="jump";visual_state="rise"
   stretch=Vector2(0.985,1.025)
  elif velocity.y<30:
   key="jump";visual_state="apex"
   stretch=Vector2(1.015,0.99)
  else:
   key="fall";visual_state="fall"
   var fall_amount:=clampf(velocity.y/1000.0,0,1)
   stretch=Vector2(1.0-0.022*fall_amount,1.0+0.04*fall_amount)
   # Arms and bent legs keep moving throughout the descent, even vertically.
   tilt=facing*0.025*fall_amount+sin(air_time*7.0)*0.018*fall_amount
  tilt+=clampf(velocity.x/maxf(speed,1.0),-1,1)*(-0.025 if visual_state=="fall" else 0.04)
 elif moving:
  key="run"+str(1+int(run_phase*4.0)%4);visual_state="run"
  # A small alternating weight shift; acceleration adds a gentle forward lean.
  tilt=facing*(0.025+sin(run_phase*TAU)*0.008)*speed_ratio+acceleration_lean*0.03
 else:
  var breath:=sin(idle_time*2.4)
  stretch=Vector2(1.0-breath*0.007,1.0+breath*0.012)
  tilt=sin(idle_time*1.2)*0.008
  if stop_time>0:
   var settle:=sin((1.0-stop_time/0.16)*PI)
   stretch*=Vector2(1.0+settle*0.025,1.0-settle*0.025)
   tilt-=facing*settle*0.022

 if grounded and not show_hurt_pose and not pushing and land_time>0:
  visual_state="land"
  var t:=1.0-land_time/LAND_DURATION
  # Absorb the impact early, then ease out while the knees straighten.
  var compression:=1.0-pow(1.0-clampf(t/0.25,0,1),2.0)
  if t>0.25:compression=1.0-smoothstep(0.25,1.0,t)
  var squash:=compression*(0.025+0.065*landing_strength)
  stretch=Vector2(1.0+squash*0.5,1.0-squash)
  offset.y=0.0
  # Both a running and a standing landing show contact and compression.
  # Show the knee recovery before resuming the stride; input stays immediate.
  if not moving or LAND_DURATION-land_time<LAND_RUN_RECOVERY:
   key="land";height=74.0

 if moving or not grounded or pushing or hurt_time>0:
  pickup_pose_active=false
 if happy>0 and hurt_time<=0 and not pushing:
  var u:=clampf(celebration_age/maxf(celebration_duration,0.01),0,1)
  var joy:=sin(u*PI)
  if pickup_pose_active and land_time<=0:
   visual_state="celebrate"
   if u<0.15:key="surprised";height=90.0
   elif u<0.78:key="happy";height=88.0
   else:key="front"
   offset.y=-joy*1.5
   tilt+=sin(u*TAU)*joy*0.035
  else:
   # A little happy bounce remains visible during a run/jump. The legs
   # retain their stride and a late stop cannot replay half a celebration.
   var pulse:=sin(clampf(celebration_age/0.5,0,1)*PI)
   stretch*=Vector2(1.0-pulse*0.02,1.0+pulse*0.035)
   tilt+=sin(celebration_age*TAU*2.0)*pulse*0.05
   if grounded:offset.y-=pulse*3.0

 if turn_time>0:
  stretch.x*=1.0-sin((1.0-turn_time/0.12)*PI)*0.09
 if hurt_time>0:
  var recoil:=exp(-hurt_age*8.0)
  tilt-=facing*0.16*recoil
  tilt+=sin(hurt_age*24.0)*0.028*(hurt_time/hurt_animation_duration)
  offset.x-=facing*sin(minf(hurt_age/0.22,1.0)*PI)*6.0
  stretch*=Vector2(1.0+recoil*0.065,1.0-recoil*0.06)

 if visual_state!=previous_state:state_age=0.0
 else:state_age+=delta
 if visual_state=="idle":idle_time+=delta
 else:idle_time=0.0
 var texture:Texture2D=get_sheet_texture()
 if texture:
  height=124.0
  if sheet_animation=="run" and sheet_frames.get_frame_count("run")==8:
   # Keep the soles at the existing pivot and reduce the height jump between
   # the compressed and extended drawings, retaining a little knee bend.
   height*=lerpf(1.0,297.0/RUN_POSE_HEIGHTS[sheet_frame],0.7)
  # Fixed 384px virtual canvas: every pose shares a foot pivot at y=356.
  sprite.offset=Vector2(0,-164)
 else:
  texture=pose_cache[key] if pose_cache.has(key) else DreamArt.texture(key)
  if not pose_offsets.has(key):
   var visible_rect:=texture.get_image().get_used_rect()
   pose_offsets[key]=Vector2(texture.get_width()*0.5-visible_rect.get_center().x,texture.get_height()*0.5-visible_rect.end.y)
  sprite.offset=pose_offsets[key]
 sprite.texture=texture
 visual_stretch=visual_stretch.lerp(stretch,1.0-exp(-26.0*delta))
 sprite.scale=Vector2.ONE*(height/texture.get_height())*visual_stretch
 sprite.flip_h=facing<0
 sprite.rotation=lerpf(sprite.rotation,tilt,1.0-exp(-20.0*delta))
 if grounded:offset.y+=floor_visual_offset
 sprite.position=sprite.position.lerp(offset,1.0-exp(-26.0*delta))
 var warmth:=sin(clampf(celebration_age/maxf(celebration_duration,0.01),0,1)*PI)*0.08 if happy>0 else 0.0
 sprite.modulate=Color(1.0+warmth,1.0+warmth,1.0+warmth)
 if hurt_time>0:
  var flash:=exp(-hurt_age*12.0)
  sprite.modulate=Color(1.0+flash*0.15,1.0-flash*0.3,1.0-flash*0.3)
 if invulnerable>0 and not (hurt_time>0 and hurt_age<0.18):
  sprite.modulate.a=0.7+0.3*(0.5+0.5*cos(invulnerable*TAU*5.0))
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
   sheet_animation="idle";sheet_frame=sheet_frame_at("idle",idle_time,true)
  "run":
   sheet_animation="run";sheet_frame=run_sheet_frame()
  "takeoff","boost":
   if air_time<TAKEOFF_DURATION:
    sheet_animation="takeoff";sheet_frame=sheet_frame_at("takeoff",air_time)
   else:
    sheet_animation="rise";sheet_frame=sheet_frame_at("rise",air_time-TAKEOFF_DURATION)
  "rise":
   # Continue from takeoff, not from a velocity-derived frame halfway through.
   sheet_animation="rise";sheet_frame=sheet_frame_at("rise",maxf(0.0,air_time-TAKEOFF_DURATION))
  "apex":
   sheet_animation="rise";sheet_frame=sheet_frames.get_frame_count("rise")-1
  "fall":
   sheet_animation="fall";sheet_frame=sheet_frame_at("fall",state_age,true)
  "land":
   if ground_speed>8.0 and LAND_DURATION-land_time>=LAND_RUN_RECOVERY:
    sheet_animation="run";sheet_frame=run_sheet_frame()
   else:
    sheet_animation="land";sheet_frame=sheet_frame_at("land",LAND_DURATION-land_time)
  "hurt":
   if not sheet_frames.has_animation("hurt"):return null
   sheet_animation="hurt"
   var progress:=1.0-hurt_time/maxf(hurt_animation_duration,0.01)
   sheet_frame=sheet_frame_at("hurt",progress*sheet_duration("hurt"))
  "celebrate":
   sheet_animation="collect_star" if celebration_kind=="star_key" else "collect_diamond"
   var progress:=celebration_age/maxf(celebration_duration,0.01)
   sheet_frame=sheet_frame_at(sheet_animation,progress*sheet_duration(sheet_animation))
 if sheet_animation.is_empty():return null
 return sheet_frames.get_frame_texture(sheet_animation,sheet_frame)


func run_sheet_frame() -> int:
 var count:=sheet_frames.get_frame_count("run")
 if count!=8:return mini(int(run_phase*count),maxi(0,count-1))
 var progress:=fposmod(run_phase,1.0)*8.0
 for i in RUN_FRAME_ORDER.size():
  if progress<RUN_FRAME_HOLDS[i]:return RUN_FRAME_ORDER[i]
  progress-=RUN_FRAME_HOLDS[i]
 return RUN_FRAME_ORDER[-1]

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
 pickup_pose_active=is_on_floor() and absf(velocity.x)<8 and land_time<=0
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
  draw_set_transform(Vector2(0,floor_visual_offset+1),get_floor_normal().angle()+PI*0.5,Vector2(1,0.2))
  draw_circle(Vector2.ZERO,19,Color(0.15,0.3,0.32,0.13))
  if land_time>0:
   var t:=1.0-land_time/LAND_DURATION
   draw_arc(Vector2.ZERO,20+t*21,0,TAU,24,Color(0.82,1,0.89,(1-t)*0.32),2,true)
  draw_set_transform(Vector2.ZERO)
 for echo in pickup_echoes:
  var t:float=clampf(echo.age/0.42,0,1)
  var eased:=1.0-pow(1.0-t,3)
  var center:Vector2=to_local(echo.origin).lerp(Vector2(0,-55),eased)+Vector2(0,-sin(t*PI)*22)
  var size:=lerpf(30,8,eased)
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
 if hurt_time>0 and visual_state!="hurt":
  var hurt_age:=hurt_animation_duration-hurt_time
  for i in 3:
   var angle:=hurt_age*6.0+float(i)*TAU/3.0
   var center:=Vector2(cos(angle)*22,-110+sin(angle)*6)
   var points:=PackedVector2Array()
   for point in 10:
    var direction:=float(point)*PI/5.0-PI*0.5
    points.append(center+Vector2(cos(direction),sin(direction))*(4.2 if point%2==0 else 1.9))
   draw_colored_polygon(points,Color(1.0,0.86,0.4,clampf(hurt_time/0.2,0,1)))
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
 pickup_pose_active=false;air_time=0.0;boost_flash=0.0;ground_distance=0.0;ground_speed=0.0
 run_phase=0.0;idle_time=0.0;stop_time=0.0;turn_time=0.0;buffer=0.0;coyote=0.0
 floor_motion_y=0.0;floor_visual_offset=0.0
 Progress.sfx("hurt");hurt_time=hurt_animation_duration
 get_tree().call_group("level","respawn_player")
 invulnerable=1.3

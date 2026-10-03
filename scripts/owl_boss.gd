@tool
extends Node2D
## Fixed root = arena floor. The body travels locally; level.gd keeps its contract.
@export var hp := 5
@export var left := 4550.0
@export var right := 5570.0
@export var keeper_art:Texture2D
@export var pose_regions:Array[Rect2] = [Rect2(43,88,612,501), Rect2(652,110,570,501), Rect2(95,721,451,459), Rect2(712,713,414,461)]
const POSE_FEET := [Vector2(382,574),Vector2(994,596),Vector2(376,1175),Vector2(978,1173)]
const OUTRO_TEXT := "Děkuji, Bite! Temnota je pryč. Vezmi si mou hvězdu a otevři bránu do paláce — Jiskra tě potřebuje!"
const PEARL = preload("res://scripts/owl_projectile.gd")
const STOMP_HEIGHT := 158.0
var max_hp := 5
var defeated := false
var dialogue_started := false
var dialogue_completed := false
var star_released := false
var state := "sleep"
var timer := 0.0
var clock := 0.0
var attacks := 0
var body_offset := Vector2.ZERO
var move_from := Vector2.ZERO
var move_to := Vector2.ZERO
var dive_point := Vector2.ZERO
var direction := -1.0
var high_flight := false
var fired := false
var impact_age := 10.0
var projectiles:Node2D
var health_label:Label
var cue:Label
var encounter_camera:Camera2D
var saved_camera_limits:=Vector2i.ZERO
var camera_focused:=false
func _sweep_seconds() -> float:
	return 1.8 if hp==1 else (2.0 if hp<=3 else 2.3)
func _rest_seconds() -> float:
	return 2.8 if hp==1 else (3.1 if hp<=3 else 3.4)
func _ready() -> void:
	max_hp=maxi(1,hp)
	body_offset=Vector2(right-position.x-90.0,-300)
	z_index=2
	if Engine.is_editor_hint():queue_redraw();return
	add_to_group("boss")
	projectiles=Node2D.new();projectiles.name="ShadowPearls";add_child(projectiles)
	health_label=_make_label(Vector2(-165,-230),330,29,Color("ffe193"))
	cue=_make_label(Vector2(-200,-274),400,22,Color("ffffff"))
	queue_redraw()
func _make_label(at:Vector2,span:float,font_size:int,color:Color) -> Label:
	var label:=Label.new()
	label.position=at;label.size=Vector2(span,38)
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.add_theme_color_override("font_outline_color",Color("24274d"))
	label.add_theme_constant_override("outline_size",5)
	add_child(label)
	return label
func get_dialogue_frames() -> SpriteFrames:
	var frames:=SpriteFrames.new()
	frames.rename_animation("default","idle")
	if keeper_art!=null:
		var picture:=AtlasTexture.new()
		picture.atlas=keeper_art;picture.region=_region(3);picture.filter_clip=true
		frames.add_frame("idle",picture)
	return frames
func _region(index:int) -> Rect2:
	if pose_regions.size()>index:return pose_regions[index]
	if keeper_art==null:return Rect2()
	var cell:=Vector2(keeper_art.get_width(),keeper_art.get_height())/2.0
	return Rect2(Vector2(index%2,index/2)*cell,cell)
func _clear_projectiles() -> void:
	if not is_instance_valid(projectiles):return
	for pearl in projectiles.get_children():
		pearl.set_physics_process(false)
		pearl.queue_free()
func _focus_arena() -> void:
	if camera_focused:return
	var player=get_tree().get_first_node_in_group("player")
	if player==null:return
	encounter_camera=player.get_node_or_null("Camera2D") as Camera2D
	if encounter_camera==null:return
	saved_camera_limits=Vector2i(encounter_camera.limit_left,encounter_camera.limit_right)
	var half_view:=maxf(640.0,get_viewport_rect().size.x*0.5/encounter_camera.zoom.x)
	var center:=(left+right)*0.5
	encounter_camera.limit_left=int(center-half_view)
	encounter_camera.limit_right=int(center+half_view)
	camera_focused=true
func _restore_camera() -> void:
	if camera_focused and is_instance_valid(encounter_camera):
		encounter_camera.limit_left=saved_camera_limits.x
		encounter_camera.limit_right=saved_camera_limits.y
	camera_focused=false
func reset_encounter() -> void:
	if defeated:return
	_restore_camera()
	hp=max_hp;state="sleep";timer=0;clock=0;attacks=0;fired=false
	direction=-1;high_flight=false;impact_age=10
	dialogue_started=false;dialogue_completed=false;star_released=false
	body_offset=Vector2(right-position.x-90.0,-300)
	move_from=body_offset;move_to=body_offset;dive_point=Vector2.ZERO
	_clear_projectiles()
	queue_redraw()
func _begin_flight() -> void:
	_focus_arena()
	state="flight_warn";timer=0;fired=false
	high_flight=hp==1 and attacks%2==1
	direction=-1.0 if body_offset.x>0 else 1.0
	var start_x:=right-40 if direction<0 else left+40
	move_from=body_offset
	move_to=Vector2(start_x-position.x,-235 if high_flight else -15)
	Progress.sfx("boss_stomp_warn")
func _spawn_pearls(player:CharacterBody2D) -> void:
	if hp>3 or fired:return
	fired=true
	var origin:=global_position+body_offset+Vector2(0,-80)
	var target:=player.global_position+Vector2(0,-38)
	var aim:=(target-origin).normalized()
	for angle in ([-0.23,0.23] if hp==1 else [0.0]):
		var pearl:=PEARL.new()
		pearl.position=projectiles.to_local(origin)
		pearl.velocity=aim.rotated(angle)*(195.0 if hp==1 else 180.0)
		pearl.arena=Rect2(Vector2(left-115,global_position.y-610),Vector2(right-left+230,665))
		projectiles.add_child(pearl)
	Progress.sfx("boost")
func _land() -> void:
	body_offset=dive_point
	state="rest";timer=0;impact_age=0
	# Landing is a clear opportunity: no residual shot can punish the stomp.
	_clear_projectiles()
	Progress.sfx("land")
func _stomp(player:CharacterBody2D) -> void:
	if state!="rest" or player.frozen:return
	hp=maxi(0,hp-1)
	player.velocity.y=-570;player.boost_used=false
	player.invulnerable=maxf(player.invulnerable,0.45)
	_clear_projectiles()
	state="hurt";timer=0
	Progress.sfx("boss_hit")
	if hp==0:
		defeated=true;state="defeated"
		Progress.sfx("boss_free")
func _body_contact(player:CharacterBody2D) -> void:
	if state not in ["sweep","dive","rest"] or player.frozen:return
	var feet:=global_position+body_offset
	var head:=feet.y-STOMP_HEIGHT
	var descending:bool=player.velocity.y>0
	var crosses_head:bool=player.previous_bottom<=head+14 and player.global_position.y>=head-10
	if state=="rest" and descending and crosses_head and absf(player.global_position.x-feet.x)<68:
		_stomp(player);return
	# Rest and warning are safe. Only the moving body during an attack hurts.
	if state=="rest":return
	var contact:=Rect2(feet+Vector2(-61,-137),Vector2(122,119))
	var player_body:=Rect2(player.global_position+Vector2(-19,-72),Vector2(38,68))
	if contact.intersects(player_body):player.hurt()
func _physics_process(delta:float) -> void:
	if Engine.is_editor_hint():return
	var player:=get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player==null:return
	clock+=delta;timer+=delta;impact_age+=delta
	match state:
		"sleep":
			if player.position.x>=left-60 and player.position.x<=right+100:_begin_flight()
		"flight_warn":
			body_offset=move_from.lerp(move_to,smoothstep(0,1.4,timer))
			if timer>=1.4:
				state="sweep";timer=0;attacks+=1
				move_from=body_offset
				move_to=Vector2((left+40 if direction<0 else right-40)-position.x,body_offset.y)
				Progress.sfx("boss_push")
		"sweep":
			var duration:=_sweep_seconds()
			body_offset=move_from.lerp(move_to,clampf(timer/duration,0,1))
			if timer>=duration:
				state="dive_warn";timer=0
				move_from=body_offset
				# Land in the two open bays, never through a stone refuge.
				var landing_x:float=left+365 if player.position.x<position.x else right-285
				dive_point=Vector2(landing_x-position.x,0)
				move_to=dive_point+Vector2(0,-290)
		"dive_warn":
			body_offset=move_from.lerp(move_to,smoothstep(0,0.65,timer))
			if timer>=0.7:_spawn_pearls(player)
			if timer>=1.45:
				state="dive";timer=0;move_from=body_offset
				Progress.sfx("boss_push")
		"dive":
			body_offset=move_from.lerp(dive_point,pow(clampf(timer/0.62,0,1),2))
			if timer>=0.62:_land()
		"rest":
			if timer>=_rest_seconds():_begin_flight()
		"hurt":
			if timer>=0.85:_begin_flight()
		"defeated":
			if timer>=1.1 and not dialogue_started and player.is_on_floor():
				var game=get_tree().get_first_node_in_group("game")
				if game and game.has_method("begin_owl_dialogue"):
					dialogue_started=game.begin_owl_dialogue(self)
	_body_contact(player)
	_update_labels()
	queue_redraw()
func _update_labels() -> void:
	if not is_instance_valid(health_label):return
	health_label.visible=state!="sleep" and not defeated
	health_label.position=body_offset+Vector2(-165,-221)
	health_label.text="♥".repeat(hp)+"♡".repeat(max_hp-hp)
	cue.position=body_offset+Vector2(-200,-262)
	cue.visible=state in ["flight_warn","dive_warn","rest"]
	match state:
		"flight_warn":cue.text="Vysoký přelet — zůstaň dole!" if high_flight else "Nízký přelet — vyskoč!"
		"dive_warn":cue.text="Pozor na svítící kruh!"
		"rest":cue.text="Teď skoč na hlavu!"
func finish_guardian_dialogue() -> void:
	if not defeated or not dialogue_started or dialogue_completed:return
	dialogue_completed=true;star_released=true
	_restore_camera()
	var level=get_tree().get_first_node_in_group("level")
	if level:level.boss_alive=false
	var star=preload("res://scenes/star_key.tscn").instantiate()
	star.name="OwlGuardianStar"
	var player=get_tree().get_first_node_in_group("player")
	# Reachable on the solid floor, toward the portal; never above a sealed exit.
	star.position=Vector2(clampf(player.position.x+105,left+100,right-60),position.y-38)
	get_parent().add_child(star)
	Progress.sfx("repair")
func _draw() -> void:
	var display_state:=state
	var feet:=body_offset
	var resting:bool=display_state in ["rest","hurt","defeated"]
	if display_state=="sleep":feet.y+=sin(clock*2.0)*6.0
	elif not resting:feet.y+=sin(clock*7.0)*3.0
	if state in ["dive_warn","dive"]:
		var glow:=0.5+0.3*sin(clock*9)
		draw_set_transform(dive_point,0,Vector2(1,0.28))
		draw_circle(Vector2.ZERO,90,Color(0.78,0.41,1.0,glow*0.3))
		draw_arc(Vector2.ZERO,90,0,TAU,48,Color(0.91,0.68,1,glow),5,true)
		draw_set_transform(Vector2.ZERO)
	if state=="flight_warn":
		var y:=move_to.y-68
		draw_line(Vector2(left-position.x,y),Vector2(right-position.x,y),Color(0.84,0.62,1,0.35),4,true)
		for x in range(int(left-position.x)+60,int(right-position.x),120):
			var tip:=Vector2(x,y)
			draw_polyline(PackedVector2Array([tip+Vector2(-direction*15,-8),tip,tip+Vector2(-direction*15,8)]),Color("e6c7ff"),3,true)
	var freed:=clampf(timer/1.1,0,1) if defeated else 0.0
	if not defeated or freed<1:
		draw_circle(feet+Vector2(0,-83),104,Color(0.45,0.23,0.8,0.16*(1-freed)))
		for i in 7:
			var angle:=clock*1.2+i*TAU/7
			draw_circle(feet+Vector2(cos(angle)*100,-83+sin(angle)*73),5,Color(0.82,0.59,1,0.65*(1-freed)))
	var pose:=3 if defeated else (2 if resting else (0 if sin(clock*7)>0 else 1))
	var squash:=exp(-impact_age*7.0)*0.12
	if keeper_art!=null:
		var region:=_region(pose)
		# Equal source-pixel scale preserves the same head/body size across poses.
		var factor:=0.40
		var scale_x:=(1.0+squash)*(-1.0 if direction<0 else 1.0)
		var scale_y:=1.0-squash
		draw_set_transform(feet,0.035*sin(clock*7) if not resting else 0,Vector2(scale_x,scale_y))
		var tint:=Color(1.4,1.25,1.5) if state=="hurt" and int(timer*14)%2==0 else Color.WHITE
		var anchor:Vector2=POSE_FEET[pose]
		draw_texture_rect_region(keeper_art,Rect2((region.position-anchor)*factor,region.size*factor),region,tint)
		draw_set_transform(Vector2.ZERO)
	else:
		# Editor fallback while an external atlas is importing.
		draw_circle(feet+Vector2(0,-85),70,Color("aaa0d7"))
		draw_circle(feet+Vector2(-28,-103),24,Color("f5ecdb"))
		draw_circle(feet+Vector2(28,-103),24,Color("f5ecdb"))
	if state=="rest":
		for i in 3:
			var angle:=clock*3+i*TAU/3
			draw_circle(feet+Vector2(cos(angle)*44,-182+sin(angle)*10),5,Color("ffe99a"))
	if impact_age<0.55:
		draw_set_transform(Vector2(feet.x,0),0,Vector2(1,0.3))
		draw_arc(Vector2.ZERO,25+impact_age*160,0,TAU,40,Color(0.88,0.84,1,1-impact_age/0.55),3,true)
		draw_set_transform(Vector2.ZERO)

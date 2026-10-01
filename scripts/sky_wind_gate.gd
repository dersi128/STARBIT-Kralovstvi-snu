@tool
extends Node2D
## Páka vypne mlýn na omezenou dobu. Proud i jeho účinek sledují stejnou dráhu.
@export_group("Vypnutí")
@export_range(1,30,0.5) var off_seconds := 10.0
# Read old scene overrides without exposing a second, conflicting wind control.
@export_storage var wind_area:Rect2:
	get:return Rect2(wind_origin-Vector2(wind_length,wind_width*0.5),Vector2(wind_length,wind_width))
	set(value):
		wind_origin=Vector2(value.end.x,value.get_center().y)
		wind_length=value.size.x
		wind_width=value.size.y
@export_group("Vítr")
## Začátek proudu vůči páce. V editoru jej označuje modrý bod.
@export var wind_origin := Vector2(1910,-170):
	set(value):wind_origin=value;queue_redraw()
## Dosah od začátku ke konci proudu, v pixelech.
@export_range(32,6000,1,"or_greater","suffix:px") var wind_length := 1660.0:
	set(value):wind_length=maxf(32,value);queue_redraw()
## Celá šířka pásu větru, v pixelech.
@export_range(16,3000,1,"or_greater","suffix:px") var wind_width := 1900.0:
	set(value):wind_width=maxf(16,value);queue_redraw()
## 0° doprava, 90° dolů, 180° doleva, -90° nahoru. Lze foukat i šikmo.
@export_range(-180,180,1,"degrees") var wind_angle_degrees := 180.0:
	set(value):wind_angle_degrees=value;queue_redraw()
## Prohnutí středu proudu do oblouku. Nula = rovný proud, znaménko mění stranu.
@export_range(-1500,1500,1,"suffix:px") var wind_curve := 0.0:
	set(value):wind_curve=value;queue_redraw()
@export_range(0,1500,10,"or_greater","suffix:px/s") var wind_force := 620.0
## Pomocný obrys a šipky se zobrazují pouze v editoru.
@export var show_wind_preview := true:
	set(value):show_wind_preview=value;queue_redraw()
@export_group("Vzhled mlýna")
@export var mill_offset := Vector2(2030,-140):
	set(value):mill_offset=value;_redraw_mill()
@export var mill_height := 235.0:
	set(value):mill_height=value;_redraw_mill()
@export var mill_mirrored := true:
	set(value):mill_mirrored=value;_redraw_mill()
var remaining := 0.0
var occupied_before := false
var previous_position := Vector2.ZERO
var previous_valid := false
var last_deaths := -1
var clock := 0.0
var switch_age := 1.0
var countdown:Label
var canvas:CanvasLayer
var rotor_angle:=0.0
var rotor_speed:=0.0
var visual_clock:=0.0
var visual_wind:=1.0
var mill_art:Node2D
const MILL=preload("res://assets/wind_gate/windmill_parts.png")
const LEVER=preload("res://assets/wind_gate/lever.png")
const GUST=preload("res://assets/wind_gate/gust.png")
const FONT=preload("res://assets/menu/pause/Nunito.ttf")
const LEVER_ANCHORS=[Vector2(305,495),Vector2(720,495),Vector2(1178,495),Vector2(234,990),Vector2(722,994),Vector2(1178,994)]
const LEVER_RECTS=[Rect2(130,42,340,463),Rect2(560,125,385,380),Rect2(1000,150,395,365),Rect2(95,550,435,465),Rect2(550,540,360,480),Rect2(1015,540,340,480)]
const GUST_RECTS=[Rect2(32,320,220,160),Rect2(303,323,310,164),Rect2(643,274,382,245),Rect2(1028,264,410,260),Rect2(24,595,375,212),Rect2(420,600,330,225),Rect2(782,643,334,166),Rect2(1160,670,235,125)]
func _ready() -> void:
	# After Bit (0), before his camera (10): it follows the corrected position.
	process_physics_priority=5
	z_index=0
	# Only the scenery is sent backwards. The lever stays at the walk line.
	mill_art=MillArtwork.new();mill_art.name="MillBackground";mill_art.gate=self
	mill_art.z_as_relative=false;mill_art.z_index=-8
	add_child(mill_art,false,Node.INTERNAL_MODE_BACK)
	if Engine.is_editor_hint():return
	canvas=CanvasLayer.new();canvas.layer=4;add_child(canvas)
	countdown=Label.new();countdown.mouse_filter=Control.MOUSE_FILTER_IGNORE
	countdown.size=Vector2(640,38);countdown.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	countdown.add_theme_font_override("font",FONT);countdown.add_theme_font_size_override("font_size",25)
	countdown.add_theme_color_override("font_outline_color",Color("203e57"));countdown.add_theme_constant_override("outline_size",6)
	canvas.add_child(countdown);_update_counter()
func wind_is_on() -> bool:return remaining<=0.0
func disable_wind() -> void:
	if not wind_is_on():return
	remaining=off_seconds;switch_age=0
	Progress.sfx("checkpoint")
func reset_gate() -> void:
	remaining=0;occupied_before=false;previous_valid=false;switch_age=1
func _physics_process(delta:float) -> void:
	if Engine.is_editor_hint():return
	clock+=delta;switch_age+=delta
	var player:=get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player==null:return
	if last_deaths>=0 and player.deaths!=last_deaths:reset_gate()
	last_deaths=player.deaths
	var was_off:=remaining>0
	remaining=maxf(0,remaining-delta)
	if was_off and remaining<=0:switch_age=0
	var feet:=to_local(player.global_position)
	var occupied:=player.is_on_floor() and absf(feet.x)<52 and absf(feet.y)<14
	# Standing on the lever cannot keep extending the ten-second window.
	if occupied and not occupied_before:disable_wind()
	occupied_before=occupied
	var local_direction:=wind_direction_at(feet)
	if wind_is_on() and wind_force>0 and local_direction!=Vector2.ZERO and not player.frozen:
		var direction:Vector2=(to_global(feet+local_direction)-player.global_position).normalized()
		# Stop travel against the stream, including a moving cloud carrying Bit.
		# Use collision-aware motion instead of teleporting through nearby terrain.
		var motion:Vector2=player.global_position-previous_position
		if previous_valid and motion.length()<80:
			var against:=minf(motion.dot(direction),0.0)
			if against<0:player.move_and_collide(-direction*against)
		player.velocity+=direction*maxf(0,wind_force-player.velocity.dot(direction))
	previous_position=player.global_position;previous_valid=true
	_update_counter();queue_redraw()
func _wind_point(t:float,lateral:float=0.0) -> Vector2:
	return wind_origin+Vector2(wind_length*t,4.0*wind_curve*t*(1.0-t)+lateral).rotated(deg_to_rad(wind_angle_degrees))
func _wind_tangent(t:float) -> Vector2:
	return Vector2(wind_length,4.0*wind_curve*(1.0-2.0*t)).normalized().rotated(deg_to_rad(wind_angle_degrees))
func wind_direction_at(point:Vector2) -> Vector2:
	# The same cross-sections define gameplay, gusts and the inspector preview.
	var local:Vector2=(point-wind_origin).rotated(-deg_to_rad(wind_angle_degrees))
	if local.x<0 or local.x>wind_length:return Vector2.ZERO
	var t:=local.x/wind_length
	if absf(local.y-4.0*wind_curve*t*(1.0-t))>wind_width*0.5:return Vector2.ZERO
	return _wind_tangent(t)
func _draw_wind_preview() -> void:
	var outline:=PackedVector2Array()
	for i in 25:outline.append(_wind_point(float(i)/24,-wind_width*0.5))
	for i in range(24,-1,-1):outline.append(_wind_point(float(i)/24,wind_width*0.5))
	draw_colored_polygon(outline,Color(0.4,0.8,1,0.08))
	outline.append(outline[0])
	draw_polyline(outline,Color(0.4,0.8,1,0.65),2,true)
	var center:=PackedVector2Array()
	for i in 25:center.append(_wind_point(float(i)/24))
	draw_polyline(center,Color(0.7,0.95,1,0.8),2,true)
	draw_circle(wind_origin,6,Color(0.5,0.9,1))
	for t in [0.2,0.5,0.8]:
		var point:=_wind_point(t)
		var direction:=_wind_tangent(t)
		draw_line(point-direction.rotated(0.5)*20,point,Color(0.7,0.95,1),3,true)
		draw_line(point-direction.rotated(-0.5)*20,point,Color(0.7,0.95,1),3,true)
func _update_counter() -> void:
	if not is_instance_valid(countdown):return
	countdown.visible=remaining>0
	countdown.position=Vector2((get_viewport().get_visible_rect().size.x-640)/2,64)
	countdown.text="Vítr se spustí za %.1f s"%remaining
	countdown.add_theme_color_override("font_color",Color("ffcc89") if remaining<=2 else Color("edfffb"))
	countdown.modulate.a=0.75+0.25*sin(clock*12) if remaining<=2 else 1.0
func _source(rect:Rect2,texture:Texture2D) -> Rect2:
	return Rect2(rect.position*texture.get_size()/Vector2(1448,1086),rect.size*texture.get_size()/Vector2(1448,1086))
func _process(delta:float) -> void:
	if Engine.is_editor_hint():return
	visual_clock+=delta
	rotor_speed=move_toward(rotor_speed,2.4 if wind_is_on() else 0.0,delta*5.0)
	rotor_angle=fposmod(rotor_angle+rotor_speed*delta,TAU)
	visual_wind=move_toward(visual_wind,1.0 if wind_is_on() else 0.0,delta*4.0)
	_redraw_mill()
	queue_redraw()
func _redraw_mill() -> void:
	if is_instance_valid(mill_art):mill_art.queue_redraw()
func draw_mill(canvas:Node2D) -> void:
	# Fixed masonry, one stable rotor texture, continuous rotation about its hub.
	# No animation frame ever changes the size or the position of the building.
	var art_scale:=mill_height/850.0
	var source_scale:=MILL.get_size()/Vector2(1536,1024)
	var facing:=-1.0 if mill_mirrored else 1.0
	canvas.draw_set_transform(mill_offset,0,Vector2(facing,1))
	canvas.draw_texture_rect_region(MILL,Rect2(Vector2(-389,-870)*art_scale,Vector2(800,890)*art_scale),Rect2(Vector2(26,65)*source_scale,Vector2(800,890)*source_scale))
	canvas.draw_set_transform(mill_offset+Vector2(-5*facing,-550)*art_scale,rotor_angle*facing,Vector2(facing,1))
	canvas.draw_texture_rect_region(MILL,Rect2(Vector2(-334,-356)*art_scale,Vector2(675,700)*art_scale),Rect2(Vector2(830,165)*source_scale,Vector2(675,700)*source_scale))
	canvas.draw_set_transform(Vector2.ZERO)
func _draw() -> void:
	var on:=wind_is_on()
	# Only the two registered end poses are used; fade through the switch action.
	var lowered:=clampf(switch_age/0.18,0,1) if not on else 1.0-clampf(switch_age/0.18,0,1)
	for pose in [0,2]:
		var lever_rect:Rect2=LEVER_RECTS[pose]
		var anchor:Vector2=LEVER_ANCHORS[pose]
		draw_texture_rect_region(LEVER,Rect2((lever_rect.position-anchor)*0.26,lever_rect.size*0.26),_source(lever_rect,LEVER),Color(1,1,1,lowered if pose==2 else 1.0-lowered))
	if visual_wind>0:
		# Registered sprites flow continuously along the actual wind direction.
		var lanes:=clampi(ceili(wind_width/350.0),1,3)
		for lane in lanes:
			var lateral:=((float(lane)+0.5)/lanes-0.5)*wind_width
			for i in 6:
				var t:=fposmod(float(i)/6.0+lane*0.17+visual_clock*300/wind_length,1.0)
				var source:Rect2=GUST_RECTS[(i+lane)%GUST_RECTS.size()]
				var width:=minf(250,minf(wind_length*0.45,wind_width/lanes*0.8))
				var size:=Vector2(width,width*source.size.y/source.size.x)
				draw_set_transform(_wind_point(t,lateral),_wind_tangent(t).angle()-PI)
				draw_texture_rect_region(GUST,Rect2(-size*0.5,size),_source(source,GUST),Color(1,1,1,0.45*visual_wind*sin(PI*t)))
		draw_set_transform(Vector2.ZERO)
	var text:="Vypnout vítr" if on else "Vítr vypnutý"
	var text_size:=FONT.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,18)
	draw_string(FONT,Vector2(-text_size.x/2,-132),text,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("fff2ca"))
	if Engine.is_editor_hint() and show_wind_preview:_draw_wind_preview()

class MillArtwork extends Node2D:
	var gate:Node2D
	func _draw() -> void:
		if is_instance_valid(gate):gate.draw_mill(self)

@tool
extends Node2D
## A repeatable 10-second wind switch, local to level 6; no global player changes.
@export_range(1,30,0.5) var off_seconds := 10.0
@export var wind_area := Rect2(250,-1120,1660,1900)
@export var mill_offset := Vector2(2030,-140):
	set(value):mill_offset=value;_redraw_mill()
@export var mill_height := 235.0:
	set(value):mill_height=value;_redraw_mill()
@export var mill_mirrored := true:
	set(value):mill_mirrored=value;_redraw_mill()
@export var wind_force := 620.0
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
	if wind_is_on() and wind_area.has_point(feet) and not player.frozen:
		# Run after Bit: opposing input and a moving cloud cannot carry him through.
		if previous_valid and absf(player.global_position.x-previous_position.x)<80:
			player.global_position.x=minf(player.global_position.x,previous_position.x)
		player.velocity.x=minf(player.velocity.x,-wind_force)
	previous_position=player.global_position;previous_valid=true
	_update_counter();queue_redraw()
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
		# Each gust keeps its shape and fades at the ends instead of swapping frames.
		var stream_y:=mill_offset.y-70
		for i in 6:
			var t:=fposmod(float(i)/6.0-visual_clock*300/wind_area.size.x,1.0)
			var x:=wind_area.position.x+t*wind_area.size.x
			var y:=lerpf(-50,stream_y,t)+sin(visual_clock*2+i)*22
			var source:Rect2=GUST_RECTS[i%GUST_RECTS.size()]
			var size:=Vector2(250,250*source.size.y/source.size.x)
			draw_texture_rect_region(GUST,Rect2(Vector2(x,y)-size*0.5,size),_source(source,GUST),Color(1,1,1,0.55*visual_wind*sin(PI*t)))
	var text:="Vypnout vítr" if on else "Vítr vypnutý"
	var text_size:=FONT.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,18)
	draw_string(FONT,Vector2(-text_size.x/2,-132),text,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("fff2ca"))
	if Engine.is_editor_hint():draw_rect(wind_area,Color(0.4,0.8,1,0.08))

class MillArtwork extends Node2D:
	var gate:Node2D
	func _draw() -> void:
		if is_instance_valid(gate):gate.draw_mill(self)

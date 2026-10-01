@tool
extends Node2D
## A visible pickup -> carried core -> socket -> flowing energy sequence.
@export_enum("repair", "selector", "core") var kind := "repair"
@export var caption := "Vlož jádro"
@export var done_caption := "Proud obnoven"
@export var requires: NodePath
@export var targets: Array[NodePath] = []
@export var wind_travel := Vector2(1000,-180)
@export var router: NodePath
@export var route_index := 0
@export var repair_seconds := 1.3
var active := false
var progress := 0.0
var occupied_before := false
var clock := 0.0
var caption_visible := false
var completed_feedback := 0.0
var deposited := false
var inserting_into: Node2D
var pickup_age := 0.0
var pickup_from := Vector2.ZERO
var player: CharacterBody2D
var pulse_targets: Array[Node2D] = []
var typeface:FontVariation
var card_style:StyleBoxFlat
const SHEET=preload("res://assets/world_expansion/switches.png")
const FONT=preload("res://assets/menu/Nunito.ttf")
const CORE=preload("res://assets/sky_props/wind_core_red.png")
const STAND=preload("res://assets/sky_props/wind_core_stand.png")
const CORE_REGION=Rect2(92,113,1069,1020)
const STAND_REGION=Rect2(123,229,1008,886)
const SOCKET=Vector2(0,-82)
const FEEDBACK_SECONDS=3.0
func _ready() -> void:
	z_index=-2 if kind=="repair" else 2
	typeface=FontVariation.new();typeface.base_font=FONT;typeface.variation_opentype={0x77676874:800.0}
	if not Engine.is_editor_hint():player=get_tree().get_first_node_in_group("player") as CharacterBody2D
func _physics_process(delta:float) -> void:
	if Engine.is_editor_hint():return
	clock+=delta
	completed_feedback=maxf(0,completed_feedback-delta)
	if not is_instance_valid(player):player=get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player==null:return
	var feet:=to_local(player.global_position)
	var near:bool=absf(feet.x)<58 and absf(feet.y)<14 and player.is_on_floor() and not player.frozen
	var was_active:=active
	if kind=="core":
		if not active and not player.frozen and feet.distance_to(Vector2(0,-43))<68:
			active=true;pickup_age=0.0;pickup_from=global_position+Vector2(0,-43)
			Progress.sfx("crystal");player.happy=0.55
		if active:pickup_age+=delta
	elif kind=="selector":
		var control:=get_node_or_null(router)
		if near and not occupied_before and control and _requirement_met():control.select_route(route_index)
		active=control!=null and control.selected==route_index
		if active and not was_active and near:
			completed_feedback=FEEDBACK_SECONDS
			pulse_targets.clear()
			for path in (control.upper if route_index==0 else control.lower):
				var cloud:=control.get_node_or_null(path) as Node2D
				if cloud and global_position.distance_to(cloud.global_position)<1400:pulse_targets.append(cloud)
	else:
		var core:=get_node_or_null(requires)
		if not active:
			if near and _requirement_met() and absf(player.velocity.x)<35:
				progress=minf(1,progress+delta/maxf(repair_seconds,0.1))
			else:progress=maxf(0,progress-delta*2)
			if core!=null:
				if progress>0:core.inserting_into=self
				elif core.inserting_into==self:core.inserting_into=null
			if progress>=1:
				active=true;completed_feedback=FEEDBACK_SECONDS
				if core!=null:core.deposited=true;core.inserting_into=null
				Progress.sfx("repair");player.happy=1.0
				pulse_targets.clear()
				for path in targets:
					var target:=get_node_or_null(path) as Node2D
					if target and target.has_method("configure_wind"):
						target.configure_wind(wind_travel);pulse_targets.append(target)
	caption_visible=absf(feet.x)<230 and absf(feet.y)<180 and (not active or completed_feedback>0)
	occupied_before=near
	queue_redraw()
func _requirement_met() -> bool:
	if requires.is_empty():return true
	var requirement:=get_node_or_null(requires)
	return requirement!=null and requirement.active
func _draw_core(center:Vector2,diameter:float,strength:float=1.0) -> void:
	# Local drawing coordinates keep spark geometry stable even far into a level.
	draw_set_transform(center)
	var pulse:=0.85+0.15*sin(clock*4)
	draw_circle(Vector2.ZERO,diameter*0.70,Color(1,0.30,0.18,0.12*strength*pulse))
	draw_circle(Vector2.ZERO,diameter*0.57,Color(1,0.68,0.30,0.15*strength*pulse))
	var size:=Vector2(diameter,diameter*CORE_REGION.size.y/CORE_REGION.size.x)
	draw_texture_rect_region(CORE,Rect2(-size*0.5,size),CORE_REGION)
	for i in 3:
		var a:=clock*1.8+i*TAU/3
		var spark:=Vector2(cos(a),sin(a))*diameter*0.66
		draw_circle(spark,1.8,Color(1,0.92,0.64,0.75*strength))
	draw_set_transform(Vector2.ZERO)
func _draw() -> void:
	if kind=="core":
		if deposited:return
		if not active:
			_draw_core(Vector2(0,-43),48)
		elif is_instance_valid(player):
			var hand:=player.global_position+Vector2(player.facing*30,-35)
			var carried:=pickup_from.lerp(hand,smoothstep(0,0.38,pickup_age))
			if is_instance_valid(inserting_into):
				var t:=smoothstep(0,1,inserting_into.progress)
				carried=hand.lerp(inserting_into.to_global(SOCKET),t)+Vector2(0,-sin(t*PI)*24)
			_draw_core(to_local(carried),42)
		return
	if kind=="repair":
		# The crop ends at the feet; ground contact is exactly the node origin.
		var height:=80.0
		var size:=Vector2(height*STAND_REGION.size.x/STAND_REGION.size.y,height)
		draw_texture_rect_region(STAND,Rect2(Vector2(-size.x/2,-height),size),STAND_REGION)
		if active:_draw_core(SOCKET,44)
		if not active and progress>0:
			draw_arc(SOCKET,32,-PI/2,-PI/2+TAU*progress,40,Color("ffcf75"),4,true)
			for i in 4:
				var a:=clock*6+i*TAU/4
				draw_circle(SOCKET+Vector2(cos(a)*35,sin(a)*30),2.5,Color("ffdc89"))
		elif not active:
			# A red socket echo makes the matching shape obvious before collection.
			draw_arc(SOCKET,20,0,TAU,32,Color(1,0.38,0.34,0.2+0.12*sin(clock*3)),2,true)
	else:
		draw_texture_rect_region(SHEET,Rect2(-45,-26,90,45),Rect2(724 if active else 0,640,362,202))
	_draw_energy()
	if not Engine.is_editor_hint() and not caption_visible:return
	var text:=done_caption if active else caption
	if not active and not _requirement_met():text="Najdi červené jádro"
	elif kind=="repair" and not active:text="Vkládáš jádro…" if progress>0 else "Zastav u stojánku"
	var extent:=typeface.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,17)
	var y:=-170.0 if kind=="repair" else -88.0
	draw_style_box(_card(),Rect2(-extent.x/2-10,y,extent.x+20,30))
	draw_string(typeface,Vector2(-extent.x/2,y+21),text,HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("183e53"))
func _draw_energy() -> void:
	if completed_feedback<=0:return
	var age:=FEEDBACK_SECONDS-completed_feedback
	var alpha:=minf(1,completed_feedback)*minf(1,age*5)
	var start:=SOCKET if kind=="repair" else Vector2(0,-30)
	for target in pulse_targets:
		if not is_instance_valid(target):continue
		var end:=to_local(target.global_position)+Vector2(float(target.width)*0.5,-12)
		var curve:=PackedVector2Array()
		for i in 25:
			var t:=float(i)/24
			curve.append(start.lerp(end,t)+Vector2(0,-sin(t*PI)*65))
		draw_polyline(curve,Color(0.30,0.90,1,alpha*0.22),13,true)
		draw_polyline(curve,Color(1,0.94,0.58,alpha*0.85),3,true)
		for i in 3:
			var t:=fposmod(age*0.9+float(i)/3,1)
			var point:=start.lerp(end,t)+Vector2(0,-sin(t*PI)*65)
			draw_circle(point,6,Color(0.75,1,0.96,alpha*0.35))
			draw_circle(point,2.5,Color(1,1,0.82,alpha))
		var radius:=18+fposmod(age,0.7)*45
		draw_arc(end,radius,PI,TAU,28,Color(0.65,1,0.96,alpha*(1.0-fposmod(age,0.7)/0.7)),3,true)
func _card() -> StyleBoxFlat:
	if card_style==null:
		card_style=StyleBoxFlat.new();card_style.bg_color=Color(0.94,0.99,1,0.95)
		card_style.border_color=Color("fff3c8");card_style.set_border_width_all(2)
		card_style.set_corner_radius_all(12)
	return card_style

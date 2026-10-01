@tool
extends Node2D
## Local level mechanic: repair station, wind selector, or recoverable wind core.
@export_enum("repair", "selector", "core") var kind := "repair"
@export var caption := "Opravit mlýn"
@export var done_caption := "Mlýn běží"
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
const SHEET=preload("res://assets/world_expansion/switches.png")
const FONT=preload("res://assets/menu/pause/Nunito.ttf")
func _ready() -> void:
	z_index=2
func _physics_process(delta:float) -> void:
	if Engine.is_editor_hint():return
	clock+=delta
	var player:=get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player==null:return
	var feet:=to_local(player.global_position)
	var near:=absf(feet.x)<52 and absf(feet.y)<14 and player.is_on_floor()
	if kind=="core":
		if not active and feet.distance_to(Vector2(0,-35))<68:
			active=true;Progress.sfx("crystal")
	elif kind=="selector":
		var control:=get_node_or_null(router)
		if near and not occupied_before and control and _requirement_met():control.select_route(route_index)
		active=control!=null and control.selected==route_index
	else:
		var allowed:=_requirement_met()
		if not active:
			if near and allowed and absf(player.velocity.x)<35:
				progress=minf(1,progress+delta/maxf(repair_seconds,0.1))
			else:progress=maxf(0,progress-delta*2)
			if progress>=1:
				active=true;Progress.sfx("repair");player.happy=1.0
				for path in targets:
					var target:=get_node_or_null(path)
					if target and target.has_method("configure_wind"):target.configure_wind(wind_travel)
	occupied_before=near
	queue_redraw()
func _requirement_met() -> bool:
	if requires.is_empty():return true
	var requirement:=get_node_or_null(requires)
	return requirement!=null and requirement.active
func _draw() -> void:
	if kind=="core":
		if active:return
		draw_texture_rect_region(SHEET,Rect2(-25,-68+sin(clock*3)*3,50,64),Rect2(1205,322,240,307))
		return
	var colour:=Color("a8f4cb") if active else Color("ffd978")
	draw_texture_rect_region(SHEET,Rect2(-45,-26,90,45),Rect2(724 if active else 0,640,362,202))
	var text:=caption
	if kind=="selector" and not _requirement_met():text="Nejprve horní jádro"
	if kind=="repair":
		text=done_caption if active else caption
		if not active and progress>0:
			draw_arc(Vector2(0,-58),20,-PI/2,-PI/2+TAU*progress,32,colour,4,true)
			for i in 3:
				var angle:=clock*5+i*TAU/3
				draw_circle(Vector2(cos(angle)*28,-58+sin(angle)*22),2.5,colour)
	var size:=FONT.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,17)
	draw_style_box(_card(),Rect2(-size.x/2-10,-112,size.x+20,30))
	draw_string(FONT,Vector2(-size.x/2,-91),text,HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("183e53"))
func _card() -> StyleBoxFlat:
	var style:=StyleBoxFlat.new();style.bg_color=Color(0.94,0.99,1,0.9);style.set_corner_radius_all(10);return style

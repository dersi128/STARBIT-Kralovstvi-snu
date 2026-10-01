@tool
extends Node2D
## A persistent bell. The wooden stand stays still; the generated bell swings.
@export var tone := Color("ffda79"):
	set(value):tone=value;queue_redraw()
@export_range(80,180,1,"suffix:px") var art_height:=130.0:
	set(value):art_height=value;queue_redraw()
var active := false
var ringing := 0.0
var clock := 0.0
const ART=preload("res://assets/sky_props/bell_starbit.png")
const STAND=Rect2(90,59,924,754)
const BELL=Rect2(1148,217,476,580)
const RING_SECONDS=1.6
func _ready() -> void:z_index=-2
func _physics_process(_delta:float) -> void:
	if Engine.is_editor_hint() or active:return
	var player:=get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player==null or player.frozen:return
	var feet:=to_local(player.global_position)
	if player.is_on_floor() and absf(feet.x)<57 and absf(feet.y)<15:
		active=true;ringing=RING_SECONDS;player.happy=0.7
		Progress.sfx("checkpoint")
func _process(delta:float) -> void:
	if Engine.is_editor_hint():return
	clock+=delta;ringing=maxf(0,ringing-delta);queue_redraw()
func _draw() -> void:
	var ratio:=art_height/130.0
	var stand_size:=Vector2(STAND.size.x/STAND.size.y*art_height,art_height)
	draw_texture_rect_region(ART,Rect2(Vector2(-stand_size.x/2,-art_height),stand_size),STAND)
	var age:=RING_SECONDS-ringing
	var swing:=sin(age*18.0)*0.28*exp(-age*2.2) if ringing>0 else 0.0
	var pivot:=Vector2(0,-97)*ratio
	if active:
		draw_circle(pivot+Vector2(0,32)*ratio,43*ratio,Color(tone,0.10+0.025*sin(clock*3)))
	draw_set_transform(pivot,swing)
	var bell_size:=Vector2(66,66*BELL.size.y/BELL.size.x)*ratio
	var tint:=Color.WHITE if active else Color(0.78,0.84,0.88)
	draw_texture_rect_region(ART,Rect2(Vector2(-bell_size.x/2,-8*ratio),bell_size),BELL,tint)
	draw_set_transform(Vector2.ZERO)
	# The three existing tone colours remain visible after each bell is found.
	draw_circle(Vector2(0,-14)*ratio,5.0*ratio,Color(tone,0.95 if active else 0.3))
	if ringing>0:
		for i in 2:
			var phase:=clampf((age-float(i)*0.23)/1.2,0,1)
			if phase<=0 or phase>=1:continue
			var radius:=(32+phase*45)*ratio
			var colour:=Color(tone,sin(phase*PI)*0.55)
			draw_arc(Vector2(0,-58)*ratio,radius,-0.65,0.65,20,colour,2*ratio,true)
			draw_arc(Vector2(0,-58)*ratio,radius,PI-0.65,PI+0.65,20,colour,2*ratio,true)

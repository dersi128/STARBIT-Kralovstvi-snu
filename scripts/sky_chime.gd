@tool
extends Node2D
## A persistent, order-independent bell. Touch it from its own landing shelf.
@export var tone := Color("ffda79")
var active := false
var ringing := 0.0
var clock := 0.0
const PLATE=preload("res://assets/world_expansion/switches.png")
func _ready() -> void:z_index=2
func _physics_process(_delta:float) -> void:
	if Engine.is_editor_hint() or active:return
	var player:=get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player==null or player.frozen:return
	var feet:=to_local(player.global_position)
	if player.is_on_floor() and absf(feet.x)<57 and absf(feet.y)<15:
		active=true;ringing=1.2;player.happy=0.7
		Progress.sfx("checkpoint")
func _process(delta:float) -> void:
	if Engine.is_editor_hint():return
	clock+=delta;ringing=maxf(0,ringing-delta);queue_redraw()
func _draw() -> void:
	draw_texture_rect_region(PLATE,Rect2(-45,-22,90,42),Rect2(724 if active else 0,640,362,202))
	var ink:=Color("644127")
	draw_line(Vector2(-31,-14),Vector2(-31,-100),ink,8,true)
	draw_line(Vector2(-31,-100),Vector2(31,-100),ink,8,true)
	draw_line(Vector2(31,-100),Vector2(31,-14),ink,8,true)
	draw_line(Vector2(-29,-96),Vector2(29,-96),Color("e5b77b"),3,true)
	var turn:=sin(clock*20)*0.22*minf(ringing,1.0)
	draw_set_transform(Vector2(0,-94),turn)
	if active:draw_circle(Vector2(0,34),39,Color(tone,0.12+0.04*sin(clock*3)))
	draw_arc(Vector2(0,9),7,PI,TAU,16,ink,4,true)
	var outline:=PackedVector2Array([Vector2(-8,12),Vector2(-16,18),Vector2(-19,34),Vector2(-26,43),Vector2(-27,48),Vector2(27,48),Vector2(26,43),Vector2(19,34),Vector2(16,18),Vector2(8,12)])
	draw_colored_polygon(outline,tone if active else Color("bdcdd1"))
	var rim:=outline.duplicate();rim.append(outline[0]);draw_polyline(rim,ink,3,true)
	draw_line(Vector2(-11,22),Vector2(-14,35),Color(1,1,1,0.65),4,true)
	draw_line(Vector2(-21,43),Vector2(21,43),Color("fff4cb"),3,true)
	draw_circle(Vector2(0,52),6,ink);draw_circle(Vector2(0,51),4,tone)
	draw_set_transform(Vector2.ZERO)
	if ringing>0:
		var radius:=42+(1.2-ringing)*42
		draw_arc(Vector2(0,-57),radius,0,TAU,48,Color(tone,ringing*0.45),2,true)

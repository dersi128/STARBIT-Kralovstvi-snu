@tool
extends Node2D
## An optional garden has a lasting benefit: calm the storms farther ahead.
@export var area_size:=Vector2(330,90)
@export var rain_targets:Array[NodePath]=[]
@export var caption:="Tajná zahrada — déšť na další cestě ustal!"
var active:=false
var reveal_time:=0.0
const FONT=preload("res://assets/menu/pause/Nunito.ttf")
func _ready() -> void:z_index=2
func _physics_process(delta:float) -> void:
	if Engine.is_editor_hint():return
	reveal_time=maxf(0,reveal_time-delta)
	var player:=get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not active and player!=null and not player.frozen and player.is_on_floor():
		if Rect2(-area_size/2,area_size).has_point(to_local(player.global_position)):
			active=true;reveal_time=4.0;player.happy=1.0
			for path in rain_targets:
				var cloud:=get_node_or_null(path)
				if cloud!=null:cloud.active=false
			Progress.sfx("repair")
	queue_redraw()
func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(Rect2(-area_size/2,area_size),Color(0.75,1,0.7,0.1));return
	if reveal_time<=0:return
	var extent:=FONT.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,21)
	var alpha:=minf(1,reveal_time)
	draw_string_outline(FONT,Vector2(-extent.x/2,-170),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,21,5,Color(0.1,0.22,0.3,alpha))
	draw_string(FONT,Vector2(-extent.x/2,-170),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color(1,0.97,0.73,alpha))

extends Node
## Short finale. Death restores the full run; the checkpoint is before its trigger.
@export var clouds:Array[NodePath]=[]
@export var start_x:=0.0
@export var end_x:=0.0
@export var first_delay:=3.6
@export var interval:=1.35
var running:=false
var finished:=false
var deaths:=-1
func _physics_process(_delta:float) -> void:
	var player:=get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player==null:return
	if deaths>=0 and player.deaths!=deaths:
		running=false;finished=false
		for path in clouds:
			var cloud:=get_node_or_null(path)
			if cloud:cloud.reset_motion()
	deaths=player.deaths
	if finished:return
	if not running and player.global_position.x>=start_x and player.global_position.x<end_x:
		running=true
		for i in clouds.size():
			var cloud:=get_node_or_null(clouds[i])
			if cloud:cloud.begin_collapse(first_delay+i*interval)
	if running and player.global_position.x>=end_x:
		finished=true;running=false
		for path in clouds:
			var cloud:=get_node_or_null(path)
			if cloud:cloud.reset_motion()

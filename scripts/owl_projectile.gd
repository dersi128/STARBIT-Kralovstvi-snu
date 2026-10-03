extends Node2D
## Slow, non-homing shadow pearl. Owned by the encounter, so pause/reset clear it.
var velocity := Vector2.ZERO
var lifetime := 0.0
var arena := Rect2()
var consumed := false
func _ready() -> void:
	z_index=3
func _physics_process(delta:float) -> void:
	if consumed:return
	var previous:=global_position
	position+=velocity*delta
	lifetime+=delta
	if lifetime>7.0 or not arena.has_point(global_position):
		queue_free();return
	var player=get_tree().get_first_node_in_group("player")
	if player!=null and not player.frozen:
		var center:Vector2=player.global_position+Vector2(0,-35)
		var nearest:=Geometry2D.get_closest_point_to_segment(center,previous,global_position)
		if nearest.distance_to(center)<32.0:
			consumed=true
			player.hurt()
			queue_free()
	queue_redraw()
func _draw() -> void:
	var tail:=-velocity.normalized()
	for i in range(1,5):
		draw_circle(tail*i*10.0,16.0-i*2.5,Color(0.70,0.42,1.0,0.20-i*0.035))
	draw_circle(Vector2.ZERO,22,Color(0.66,0.29,1.0,0.18))
	draw_circle(Vector2.ZERO,13,Color("7451d2"))
	draw_arc(Vector2.ZERO,14,0,TAU,24,Color("e0c1ff"),2.5,true)
	draw_circle(Vector2(-4,-5),4,Color("f7eaff"))

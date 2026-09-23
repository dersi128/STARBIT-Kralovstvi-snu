@tool
extends Node2D
## Place at a ledge: positive Look Offset Y reveals the landing below.
@export var area_size:=Vector2(400,240):
 set(value):area_size=value;queue_redraw()
@export var look_offset:=Vector2(0,90):
 set(value):look_offset=value;queue_redraw()
@export var priority:=1
func _ready() -> void:
 if not Engine.is_editor_hint():add_to_group("camera_zones")
func contains(point:Vector2) -> bool:
 return Rect2(-area_size/2,area_size).has_point(to_local(point))
func weight_at(point:Vector2) -> float:
 var local:=to_local(point)
 var edge:=area_size/2-local.abs()
 if edge.x<=0 or edge.y<=0:return 0.0
 return smoothstep(0,80,minf(edge.x,edge.y))
func _draw() -> void:
 if not Engine.is_editor_hint():return
 draw_rect(Rect2(-area_size/2,area_size),Color(0.2,0.8,1,0.12))
 draw_rect(Rect2(-area_size/2,area_size),Color(0.2,0.8,1,0.8),false,2)
 draw_line(Vector2.ZERO,look_offset,Color(1,0.8,0.2),3)
 draw_circle(look_offset,6,Color(1,0.8,0.2))

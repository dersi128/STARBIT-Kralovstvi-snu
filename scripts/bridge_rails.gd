@tool
extends Node2D
@export var end_offset:=Vector2(800,0)
func _draw() -> void:
 # Rope handrails are attached to bank posts, with a gentle sag.
 var previous:=Vector2(0,-72)
 for i in range(1,41):
  var t:=i/40.0
  var point:=end_offset*t+Vector2(0,-72+sin(t*PI)*20)
  draw_line(previous,point,Color("553e2c"),7,true)
  draw_line(previous,point,Color("d8aa66"),3,true)
  if i%4==0:draw_line(point,end_offset*t,Color("aa7950"),3,true)
  previous=point
 for p in [Vector2.ZERO,end_offset]:
  draw_line(p+Vector2(0,10),p+Vector2(0,-95),Color("624328"),14,true)
  draw_line(p+Vector2(-2,8),p+Vector2(-2,-90),Color("b88047"),6,true)

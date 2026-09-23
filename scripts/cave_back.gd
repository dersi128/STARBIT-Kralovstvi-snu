@tool
extends Node2D
@export var size:=Vector2(2200,500)
func _ready() -> void:z_index=-3
func _draw() -> void:
 var tex:Texture2D=preload("res://assets/worldkit/earth_interior.png")
 for x in range(0,int(size.x),400):
  for y in range(0,int(size.y),400):
   var area:=Vector2(minf(400,size.x-x),minf(400,size.y-y))
   draw_texture_rect_region(tex,Rect2(Vector2(x,y),area),Rect2(Vector2.ZERO,area*tex.get_width()/400.0),Color(0.22,0.3,0.35))
 draw_rect(Rect2(Vector2.ZERO,size),Color(0.03,0.12,0.15,0.35))

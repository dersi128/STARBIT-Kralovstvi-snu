@tool
extends Node2D
## Decorative animated water; no collision or damage. Solid platforms stay readable.
@export_enum("pool","waterfall") var kind:="pool":
 set(value):kind=value;queue_redraw()
@export var size:=Vector2(600,95):
 set(value):size=value;queue_redraw()
var time:=0.0
func _ready() -> void:
 z_index=-2
func _process(delta:float) -> void:
 if Engine.is_editor_hint():return
 time+=delta;queue_redraw()
func _draw() -> void:
 var tex:Texture2D=preload("res://assets/worldkit/WaterSurface.tres") if kind=="pool" else preload("res://assets/supplied/pieces/FallsLongThin.png")
 draw_texture_rect(tex,Rect2(Vector2.ZERO,size),false,Color(1,1,1,0.8))
 if kind=="pool":
  for i in 8:
   var x:=fposmod(i*size.x/8+time*16,size.x)
   var y:=12+sin(time*1.4+i)*3
   draw_line(Vector2(x,y),Vector2(minf(x+32,size.x),y),Color(0.85,1,1,0.5),2,true)
 else:
  for i in 7:
   var y:=fposmod(i*size.y/7+time*95,size.y)
   var x:=size.x*(0.2+0.1*(i%5))
   draw_line(Vector2(x,y),Vector2(x,minf(y+35,size.y)),Color(0.8,1,1,0.35),2,true)

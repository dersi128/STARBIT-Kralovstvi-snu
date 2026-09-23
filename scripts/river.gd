@tool
extends Node2D
## Bounded river below a bridge, extending down to the landscape's base.
@export var width:=800.0
@export var depth:=1000.0
var time:=0.0
func _ready() -> void:z_index=-2
func _process(delta:float) -> void:
 if not Engine.is_editor_hint():time+=delta;queue_redraw()
func _draw() -> void:
 var top:=Color(0.12,0.64,0.77,0.9)
 var bottom:=Color(0.05,0.28,0.43,0.97)
 draw_polygon(PackedVector2Array([Vector2.ZERO,Vector2(width,0),Vector2(width,depth),Vector2(0,depth)]),PackedColorArray([top,top,bottom,bottom]))
 for i in maxi(1,int(width/75)):
  var x:=fposmod(i*75+time*12,width)
  var y:=sin(time*1.5+i)*2+5
  draw_line(Vector2(x,y),Vector2(minf(x+40,width),y),Color(0.7,0.96,1,0.65),2,true)

@tool
extends Node2D
## Earth below the playable surface. Cave bounds are in level coordinates.
@export var width:=500.0
@export var bottom:=1900.0
@export var cave:=Rect2()
func _ready() -> void:z_index=-1
func _draw() -> void:
 var tex:Texture2D=preload("res://assets/worldkit/earth_interior.png")
 var cave_local:=Rect2(cave.position-position,cave.size)
 # Repeating rock interiors preserve texture proportions; grass stays on the platform.
 var cols:=maxi(1,ceili(width/360.0))
 var cell:=width/cols
 for i in cols:
  var x:=i*cell
  var y:=70.0
  while y<bottom-position.y:
   var h:=minf(cell,bottom-position.y-y)
   var rect:=Rect2(x,y,cell+0.6,h)
   if cave.size==Vector2.ZERO or not rect.intersects(cave_local):
    draw_texture_rect_region(tex,rect,Rect2(Vector2.ZERO,Vector2(tex.get_width(),tex.get_height()*h/cell)))
   else:
    # Split at the cavity instead of drawing earth over a hidden route.
    var cut:=rect.intersection(cave_local)
    for piece in [Rect2(rect.position,Vector2(rect.size.x,cut.position.y-rect.position.y)),Rect2(Vector2(rect.position.x,cut.end.y),Vector2(rect.size.x,rect.end.y-cut.end.y)),Rect2(Vector2(rect.position.x,cut.position.y),Vector2(cut.position.x-rect.position.x,cut.size.y)),Rect2(Vector2(cut.end.x,cut.position.y),Vector2(rect.end.x-cut.end.x,cut.size.y))]:
     if piece.size.x>0 and piece.size.y>0:draw_texture_rect_region(tex,piece,Rect2((piece.position-rect.position)*tex.get_width()/cell,piece.size*tex.get_width()/cell))
   y+=cell

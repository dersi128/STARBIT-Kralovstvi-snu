@tool
extends AnimatableBody2D
## Prepared atlas piece. Origin is the walk line; collision follows Surface.
@export var texture:Texture2D:
 set(v):texture=v;queue_redraw()
@export var width:=256.0:
 set(v):width=maxf(v,32.0);_refresh()
@export var height:=150.0:
 set(v):height=maxf(v,24.0);_refresh()
@export_range(0,1) var anchor_y:=0.20:
 set(v):anchor_y=v;_refresh()
@export var surface:=PackedVector2Array([Vector2(0.1,0.2),Vector2(0.9,0.2)]):
 set(v):surface=v;_refresh()
@export var travel:=Vector2.ZERO
@export var period:=4.0
var origin:=Vector2.ZERO
var time:=0.0
func _ready() -> void:
 collision_layer=1;collision_mask=0;origin=position;_refresh()
func _refresh() -> void:
 queue_redraw()
 var shape:=get_node_or_null("CollisionPolygon2D") as CollisionPolygon2D
 if shape==null or surface.size()<2:return
 var points:=PackedVector2Array()
 for v in surface:points.append(Vector2((v.x-0.5)*width,(v.y-anchor_y)*height))
 for i in range(surface.size()-1,-1,-1):
  var v:=surface[i];points.append(Vector2((v.x-0.5)*width,(v.y-anchor_y)*height+18))
 shape.polygon=points
 shape.one_way_collision=true
func _physics_process(delta:float) -> void:
 if Engine.is_editor_hint():return
 time+=delta
 position=origin+travel*(0.5-0.5*cos(TAU*time/maxf(period,0.5)))
func _draw() -> void:
 if texture:draw_texture_rect(texture,Rect2(-width/2,-height*anchor_y,width,height),false)
 if Engine.is_editor_hint() and travel.length()>0:
  draw_line(Vector2.ZERO,travel,Color.CYAN,2)

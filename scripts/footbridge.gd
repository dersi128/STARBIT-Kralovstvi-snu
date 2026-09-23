@tool
extends AnimatableBody2D
## A usable bridge between two banks; End Offset is relative to its left bank.
@export var end_offset:=Vector2(260,0)
var width:float:
 get:return end_offset.x
func _ready() -> void:
 collision_layer=1;collision_mask=0
 var deck:=CollisionPolygon2D.new()
 deck.polygon=PackedVector2Array([Vector2.ZERO,end_offset,end_offset+Vector2(0,18),Vector2(0,18)])
 deck.one_way_collision=true
 add_child(deck)
func _draw() -> void:
 var tex:Texture2D=preload("res://assets/worldkit/WoodBridge.tres")
 var count:=maxi(1,ceili(end_offset.x/240.0))
 var angle:=end_offset.angle()
 draw_set_transform(Vector2.ZERO,angle)
 for i in count:
  var length:=end_offset.length()/count
  draw_texture_rect(tex,Rect2(i*length,-14,length+1,95),false)
 draw_set_transform(Vector2.ZERO)

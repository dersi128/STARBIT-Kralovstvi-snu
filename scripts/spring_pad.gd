@tool
extends Area2D
@export var launch_speed:=850.0
var cooldown:=0.0
func _ready() -> void:
 if not Engine.is_editor_hint():body_entered.connect(_on_body)
func _process(delta:float) -> void:
 cooldown=maxf(0,cooldown-delta);queue_redraw()
func _on_body(body:Node2D) -> void:
 if not body.is_in_group("player") or cooldown>0:return
 if body.velocity.y<0 or body.global_position.y>global_position.y+8:return
 body.velocity.y=-launch_speed;body.coyote=0;body.buffer=0;body.boost_used=false
 cooldown=0.3;Progress.sfx("boost")
func _draw() -> void:
 var compressed:=cooldown*18
 draw_style_box(_box(Color("4c9b9a")),Rect2(-40,-12,80,12))
 for i in 4:
  var y:float=-15-i*7+compressed
  draw_line(Vector2(-19,y),Vector2(19,y-4),Color("ddebf3"),4,true)
 draw_style_box(_box(Color("ffda69")),Rect2(-37,-47+compressed,74,12))
func _box(color:Color) -> StyleBoxFlat:
 var b:=StyleBoxFlat.new();b.bg_color=color;b.set_corner_radius_all(5);return b

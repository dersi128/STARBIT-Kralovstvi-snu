@tool
extends AnimatableBody2D
@export_enum("ground","island","small","stone","cloud","bridge") var style := "ground":
 set(v): style=v;queue_redraw();_refresh_collision()
@export var width := 384.0:
 set(v): width=maxf(32,v);queue_redraw();_refresh_collision()
@export var depth := 128.0:
 set(v): depth=maxf(24,v);queue_redraw();_refresh_collision()
@export var travel := Vector2.ZERO
@export var period := 4.0
var origin := Vector2.ZERO
var time := 0.0
func _ready() -> void:
 collision_layer=1
 collision_mask=0
 origin=position
 _refresh_collision()
func _refresh_collision() -> void:
 var c:=get_node_or_null("CollisionShape2D") as CollisionShape2D
 if c==null:return
 if c.shape==null:c.shape=RectangleShape2D.new()
 c.shape.size=Vector2(width,depth-15)
 c.position=Vector2(width/2,(depth-15)/2)
func _physics_process(delta: float) -> void:
 if Engine.is_editor_hint(): return
 time+=delta
 position=origin+travel*(0.5-0.5*cos(TAU*time/maxf(period,0.5)))
func _draw() -> void:
 var tex:Texture2D = preload("res://assets/worldkit/WoodBridge.tres") if style=="bridge" else DreamArt.texture(style)
 if style=="ground":
  var n := maxi(1,ceili(width/256.0))
  for i in n:
   # Use the opaque interior; alternate it to match the join exactly.
   var segment:=width/n
   draw_set_transform(Vector2((i+1)*segment if i%2 else i*segment,0),0,Vector2(-1 if i%2 else 1,1))
   draw_texture_rect_region(tex,Rect2(0,-28,segment+0.6,depth),Rect2(8,0,244,148))
   draw_set_transform(Vector2.ZERO)

 elif style=="cloud" or style=="bridge":
  var count:=maxi(1,ceili(width/260.0))
  var segment:=width/count
  for i in count:draw_texture_rect(tex,Rect2(i*segment-8,-18,segment+16,depth),false)
 else: draw_texture_rect(tex,Rect2(0,-18,width,depth),false)
 if Engine.is_editor_hint() and travel.length()>0:
  draw_line(Vector2(width/2,0),Vector2(width/2,0)+travel,Color.CYAN,3)

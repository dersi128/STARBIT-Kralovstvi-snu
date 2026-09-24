@tool
extends Area2D

const ART = preload("res://assets/worldkit/spring_pad_starbit.png")
const CLEAN_ALPHA = preload("res://shaders/spring_pad_alpha.gdshader")
# Crop transparent padding at draw time; keep the original PNG intact.
const ART_REGION = Rect2(104, 108, 1426, 762)
const CAP_END := 400.0
const BASE_START := 654.0
@export var launch_speed:=850.0
var cooldown:=0.0

func _ready() -> void:
 texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 var ink:=ShaderMaterial.new();ink.shader=CLEAN_ALPHA;material=ink
 if not Engine.is_editor_hint():body_entered.connect(_on_body)

func _process(delta:float) -> void:
 cooldown=maxf(0,cooldown-delta);queue_redraw()

func _on_body(body:Node2D) -> void:
 if not body.is_in_group("player") or cooldown>0:return
 if body.velocity.y<0 or body.global_position.y>global_position.y+8:return
 body.velocity.y=-launch_speed;body.coyote=0;body.buffer=0;body.boost_used=false
 cooldown=0.3;Progress.sfx("boost")

func _draw() -> void:
 var compressed:=cooldown*18.0
 var units:=47.0/ART_REGION.size.y
 var cap_height:float=(CAP_END-ART_REGION.position.y)*units
 var spring_height:float=(BASE_START-CAP_END)*units
 var base_height:float=(ART_REGION.end.y-BASE_START)*units
 # Top surface stays at the original height. Only the coil shortens on impact;
 # the cap moves as one piece and the wooden base stays planted on the ground.
 draw_texture_rect_region(ART,
  Rect2(-40,-47+compressed,80,cap_height),
  Rect2(ART_REGION.position,Vector2(ART_REGION.size.x,CAP_END-ART_REGION.position.y)))
 draw_texture_rect_region(ART,
  Rect2(-40,-47+cap_height+compressed,80,spring_height-compressed),
  Rect2(ART_REGION.position.x,CAP_END,ART_REGION.size.x,BASE_START-CAP_END))
 draw_texture_rect_region(ART,
  Rect2(-40,-base_height,80,base_height),
  Rect2(ART_REGION.position.x,BASE_START,ART_REGION.size.x,ART_REGION.end.y-BASE_START))

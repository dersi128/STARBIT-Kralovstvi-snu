@tool
extends Node2D
@export var hp := 3
@export var left := 3300.0
@export var right := 4150.0
var state := "sleep"
var timer := 0.0
var direction := -1.0
var attacks := 0
var defeated := false
var sprite: AnimatedSprite2D
var health_label:Label
var wrist_star:Sprite2D
var healing:ShaderMaterial
var star_released:=false
func free_bear() -> void:
 if star_released:return
 star_released=true
 get_tree().get_first_node_in_group("level").boss_alive=false
 var star=preload("res://scenes/star_key.tscn").instantiate()
 star.position=position+Vector2(55*direction,-73)
 get_parent().add_child(star)
 var destination:=position+Vector2(150,-95)
 var tween=create_tween()
 tween.tween_property(star,"position",position+Vector2(75,-230),0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 tween.tween_property(star,"position",destination,0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _ready() -> void:
 sprite=get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
 health_label=Label.new();health_label.position=Vector2(-80,-214);health_label.size=Vector2(160,42)
 health_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 health_label.add_theme_font_size_override("font_size",32)
 health_label.add_theme_color_override("font_color",Color("ff637e"))
 health_label.add_theme_color_override("font_outline_color",Color("30223f"));health_label.add_theme_constant_override("outline_size",5)
 add_child(health_label)
 healing=ShaderMaterial.new();healing.shader=preload("res://assets/bear_free.gdshader")
 sprite.material=healing
 wrist_star=Sprite2D.new();wrist_star.texture=DreamArt.texture("star")
 wrist_star.scale=Vector2(0.28,0.28);wrist_star.z_index=2;wrist_star.visible=false;add_child(wrist_star)
 if Engine.is_editor_hint():return
 add_to_group("boss")
func _physics_process(delta:float) -> void:
 if Engine.is_editor_hint():queue_redraw();return
 var p=get_tree().get_first_node_in_group("player")
 if p==null:return
 timer+=delta
 if state=="sleep" and p.position.x>left-200:state="warn";timer=0;Progress.sfx("boss_warn")
 elif state=="warn" and timer>1.2:
  direction=signf(p.position.x-position.x)
  if direction==0:direction=-1
  state="charge";timer=0;Progress.sfx("boss_push")
 elif state=="charge":
  position.x=clampf(position.x+direction*(360 if hp<=2 else 250)*delta,left,right)
  if timer>1.5 or position.x in [left,right]:state="rest";timer=0
 elif state=="rest" and timer>3.5:state="warn";timer=0;Progress.sfx("boss_warn")
 elif state=="hurt" and timer>0.7:state="warn";timer=0
 elif state=="defeated" and timer>1.5:
  free_bear()
  queue_redraw()
  return
 if state not in ["sleep","defeated","hurt"] and absf(p.position.x-position.x)<85 and p.position.y>position.y-130 and p.position.y<position.y+10:
  if state=="rest" and p.velocity.y>0 and p.previous_bottom<position.y-110:
   hp-=1;p.velocity.y=-580;Progress.sfx("boss_hit")
   state="hurt" if hp>0 else "defeated";timer=0
   if hp<=0:
    defeated=true

  elif p.position.y>position.y-95:p.hurt()
 queue_redraw()
func _process(_delta:float) -> void:
 if Engine.is_editor_hint() or sprite==null:return
 sprite.flip_h=direction<0
 var action:="idle"
 match state:
  "warn":action="warn"
  "charge":action="charge"
  "rest":action="rest"
  "hurt":action="hit"
  "defeated":action="hit" if timer<0.4 else "idle"
 sprite.play(action)
 sprite.speed_scale=1.35 if hp<=2 and state=="charge" else 1.0
 sprite.modulate=Color(1.6,1.1,1.1) if state=="hurt" and int(timer*18)%2==0 else Color.WHITE
 health_label.text="♥".repeat(maxi(0,hp))+"♡".repeat(3-clampi(hp,0,3))
 health_label.visible=not defeated
 health_label.scale=Vector2.ONE*(1.0+0.15*sin(timer*18)) if state=="hurt" else Vector2.ONE
 healing.set_shader_parameter("hit_flash",0.65 if state=="hurt" and int(timer*18)%2==0 else 0.0)
 healing.set_shader_parameter("freed",clampf(timer/1.5,0,1) if defeated else 0.0)
 wrist_star.visible=defeated
 wrist_star.position=Vector2(55*direction,-73)
 wrist_star.scale=Vector2.ONE*(0.28+sin(timer*4)*0.025)
 if defeated:
  var p=get_tree().get_first_node_in_group("player")
  if p and p.global_position.distance_to(global_position)<450:
   get_tree().call_group("game","speak",self,"Děkuji ti, Bite! Temnota je pryč. Vezmi si hvězdu a otevři bránu. Zase budu chránit stezku.","voice_bear")
 queue_redraw()

func _draw() -> void:
 if state=="rest":
  for i in 3:
   var a:=timer*4+i*TAU/3
   draw_texture_rect(DreamArt.texture("star"),Rect2(cos(a)*45-10,-165+sin(a)*9,22,22),false)
 if state=="warn":
  draw_circle(Vector2(0,-172),12,Color("ffdc6d"))
  draw_line(Vector2(0,-178),Vector2(0,-171),Color("5e4531"),3)
  draw_circle(Vector2(0,-166),1.8,Color("5e4531"))

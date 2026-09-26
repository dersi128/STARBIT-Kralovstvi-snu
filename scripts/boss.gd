@tool
extends Node2D
@export var hp := 5
@export var varied_attacks := false
@export var guardian_outro := false
var shockwaves: Array[Dictionary] = []
const STOMP_IMPACT := 0.48
const STOMP_RECOVERY := 1.05
const CHARGE_LIMIT := 3.8
const COMBO_RECOVERY := 0.82
const OUTRO_TEXT := "Děkuji, Bite! Osvobodil jsi mě. Teď se vydej do oblak — pohyblivé mráčky tě donesou blíž ke Království snů.\n\nBuď opatrný, temnota se šíří i tam. Vezmi si mou hvězdu a otevři bránu. Jiskra potřebuje tvou pomoc!"
var last_attack := "charge"
var stomps_remaining := 0
var warning_duration := 1.2
var dialogue_started := false
var dialogue_completed := false
var max_hp := 5
var stomp_landed := false
var impact_age := 10.0
var sprite_base_scale := Vector2.ONE
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
 if star_released or (guardian_outro and not dialogue_completed):return
 star_released=true
 Progress.sfx("boss_free")
 get_tree().get_first_node_in_group("level").boss_alive=false
 var star=preload("res://scenes/star_key.tscn").instantiate()
 star.position=position+Vector2(55*direction,-73)
 get_parent().add_child(star)
 var destination:=position+Vector2(150,-95)
 var tween=create_tween()
 tween.tween_property(star,"position",position+Vector2(75,-230),0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 tween.tween_property(star,"position",destination,0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func finish_guardian_dialogue() -> void:
 if not defeated or not dialogue_started or dialogue_completed:return
 dialogue_completed=true
 free_bear()

func _try_guardian_dialogue(player:CharacterBody2D) -> void:
 if dialogue_started or not player.is_on_floor():return
 var game=get_tree().get_first_node_in_group("game")
 if game==null or not game.has_method("begin_guardian_dialogue"):return
 if not is_zero_approx(player.position.x-position.x):direction=signf(player.position.x-position.x)
 dialogue_started=game.begin_guardian_dialogue(self)

func _ready() -> void:
 sprite=get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
 max_hp=maxi(1,hp)
 sprite_base_scale=sprite.scale
 z_index=2
 health_label=Label.new();health_label.position=Vector2(-112,-238);health_label.size=Vector2(224,42)
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
 sprite.frame_changed.connect(_on_animation_frame_changed)
 add_to_group("boss")
func reset_encounter() -> void:
 hp=max_hp;state="sleep";timer=0.0;attacks=0
 last_attack="charge";stomps_remaining=0;warning_duration=1.2
 dialogue_started=false;dialogue_completed=false;star_released=false
 direction=-1.0;position.x=right-100.0
 shockwaves.clear();stomp_landed=false;impact_age=10.0
 sprite.position=Vector2.ZERO;sprite.scale=sprite_base_scale;sprite.rotation=0.0
 var refuge=get_parent().get_node_or_null("BossRefuge")
 if refuge and refuge.has_method("reset_for_encounter"):refuge.reset_for_encounter()
 queue_redraw()

func _on_animation_frame_changed() -> void:
 if state=="charge" and sprite.animation==&"charge" and sprite.frame in [0,2]:
  Progress.sfx("boss_step")
func _start_warning() -> void:
 state = "stomp_warn" if varied_attacks and hp<=3 and last_attack!="stomp" else "warn"
 timer = 0.0
 warning_duration=1.2
 stomps_remaining=(2 if hp==1 else 1) if state=="stomp_warn" else 0
 var player=get_tree().get_first_node_in_group("player")
 if player and not is_zero_approx(player.position.x-position.x):direction=signf(player.position.x-position.x)
 # Telegraph the direction now; never turn into the player at launch.
 if position.x<=left+1.0 and direction<0:direction=1.0
 elif position.x>=right-1.0 and direction>0:direction=-1.0
 Progress.sfx("boss_stomp_warn" if state=="stomp_warn" else "boss_warn")

func _land_stomp() -> void:
 stomp_landed=true;impact_age=0.0
 # The second impact adds waves; the first pair keeps travelling.
 shockwaves.append_array([{"x":position.x-65.0,"direction":-1.0,"hit":false,"age":0.0}, {"x":position.x+65.0,"direction":1.0,"hit":false,"age":0.0}])
 Progress.sfx("boss_stomp")

func _physics_process(delta:float) -> void:
 if Engine.is_editor_hint():queue_redraw();return
 var p=get_tree().get_first_node_in_group("player")
 if p==null:return
 timer+=delta
 impact_age+=delta
 if state == "sleep":
  shockwaves.clear()
  attacks = 0
  if p.position.x > left - 200:_start_warning()
 elif state=="warn" and timer>1.2:
  state="charge";timer=0;attacks+=1;last_attack="charge";Progress.sfx("boss_push")
 elif state=="charge":
  var rush_speed:=350.0 if hp==1 else (325.0 if hp<=3 else 290.0)
  if not varied_attacks:rush_speed=360.0 if hp<=2 else 250.0
  position.x=clampf(position.x+direction*rush_speed*delta,left,right)
  if timer>(CHARGE_LIMIT if varied_attacks else 1.5) or position.x in [left,right]:state="rest";timer=0;Progress.sfx("boss_rest")
 elif state == "stomp_warn" and timer > warning_duration:
  state = "stomp";timer = 0;attacks += 1
  stomp_landed=false;stomps_remaining=maxi(0,stomps_remaining-1);last_attack="stomp"
 elif state == "stomp":
  if not stomp_landed and timer>=STOMP_IMPACT:_land_stomp()
  if stomps_remaining>0 and timer>COMBO_RECOVERY:
   state="stomp_warn";timer=0;warning_duration=0.40
   Progress.sfx("boss_stomp_warn")
  elif stomps_remaining==0 and timer>STOMP_RECOVERY:
   state="rest";timer=0;Progress.sfx("boss_rest")
 elif state=="rest" and timer>3.5:_start_warning()
 elif state=="hurt" and timer>0.7:_start_warning()
 elif state=="defeated" and timer>1.5:
  if guardian_outro:_try_guardian_dialogue(p)
  else:free_bear()
  queue_redraw()
  return
 for i in range(shockwaves.size()-1,-1,-1):
  var wave:Dictionary=shockwaves[i]
  var old_x:float=wave.x
  wave.x += wave.direction * (380.0 if hp <= 2 else 330.0) * delta
  wave.age+=delta
  if wave.x<left-140.0 or wave.x>right+140.0 or wave.age>4.5:
   shockwaves.remove_at(i)
   continue
  # Swept horizontal contact stays reliable during a slower frame. A jump
  # or the refuge platform places the feet above the low wave entirely.
  if not wave.hit and p.position.x>minf(old_x,wave.x)-38.0 and p.position.x<maxf(old_x,wave.x)+38.0 and p.position.y>position.y-44.0 and p.position.y<position.y+22.0:
   wave.hit=true
   p.hurt()
   queue_redraw()
   return # Respawn may already have cleared this wave array.
 if state not in ["sleep","defeated","hurt"] and not (state=="stomp" and timer<STOMP_IMPACT) and absf(p.position.x-position.x)<85 and p.position.y>position.y-130 and p.position.y<position.y+10:
  if state=="rest" and p.velocity.y>0 and p.previous_bottom<position.y-110:
   shockwaves.clear()
   hp-=1;p.velocity.y=-580;Progress.sfx("boss_hit")
   # A newly reached phase demonstrates its new attack immediately.
   if hp in [3,1]:last_attack="charge"
   state="hurt" if hp>0 else "defeated";timer=0
   if hp<=0:
    defeated=true
    stomps_remaining=0
    var refuge=get_parent().get_node_or_null("BossRefuge")
    if refuge and refuge.has_method("finish_encounter"):refuge.finish_encounter()

  elif p.position.y>position.y-95:p.hurt()
 queue_redraw()
func _process(_delta:float) -> void:
 if Engine.is_editor_hint() or sprite==null:return
 sprite.flip_h=direction<0
 var action:="idle"
 match state:
  "warn":action="warn"
  "stomp_warn", "stomp":action="attack"
  "charge":action="charge"
  "rest":action="rest"
  "hurt":action="hit"
  "defeated":action="hit" if timer<0.4 else "idle"
 var stretch:=Vector2.ONE
 var lift:=0.0
 var tilt:=0.0
 if state=="stomp_warn":
  var ready:=smoothstep(0.0,warning_duration,timer)
  sprite.animation=&"attack";sprite.pause();sprite.frame=0
  stretch=Vector2(1.0+0.10*ready,1.0-0.10*ready)
 elif state=="stomp":
  sprite.animation=&"attack";sprite.pause()
  if timer<STOMP_IMPACT:
   var flight:=clampf(timer/STOMP_IMPACT,0,1)
   lift=-58.0*sin(flight*PI)
   sprite.frame=1 if flight<0.2 else 2
   stretch=Vector2(0.96,1.05)
  else:
   var recoil:=exp(-(timer-STOMP_IMPACT)*10.0)
   stretch=Vector2(1.0+0.18*recoil,1.0-0.18*recoil)
   sprite.frame=0 if timer<STOMP_IMPACT+0.23 else 3
 else:
  sprite.play(action)
  if state=="charge":tilt=direction*0.065
 sprite.position=Vector2(0,lift)
 sprite.scale=sprite_base_scale*stretch
 sprite.rotation=tilt
 sprite.speed_scale=1.35 if hp<=2 and state=="charge" else 1.0
 sprite.modulate=Color(1.6,1.1,1.1) if state=="hurt" and int(timer*18)%2==0 else Color.WHITE
 health_label.text="♥".repeat(clampi(hp,0,max_hp))+"♡".repeat(max_hp-clampi(hp,0,max_hp))
 health_label.visible=not defeated
 health_label.scale=Vector2.ONE*(1.0+0.15*sin(timer*18)) if state=="hurt" else Vector2.ONE
 healing.set_shader_parameter("hit_flash",0.65 if state=="hurt" and int(timer*18)%2==0 else 0.0)
 healing.set_shader_parameter("freed",clampf(timer/1.5,0,1) if defeated else 0.0)
 wrist_star.visible=defeated
 wrist_star.position=Vector2(55*direction,-73)
 wrist_star.scale=Vector2.ONE*(0.28+sin(timer*4)*0.025)
 if defeated and not guardian_outro:
  var player=get_tree().get_first_node_in_group("player")
  if player and player.global_position.distance_to(global_position)<450:
   get_tree().call_group("game","speak",self,"Děkuji ti, Bite! Temnota je pryč. Vezmi si hvězdu a otevři bránu. Zase budu chránit stezku.","voice_bear")
 queue_redraw()

func _draw() -> void:
 for wave in shockwaves:
  var local_x := float(wave.x) - position.x
  var crest:=PackedVector2Array()
  for i in 21:
   var a:=PI+float(i)/20.0*PI
   crest.append(Vector2(local_x+cos(a)*34.0,-4.0+sin(a)*(36.0+2.0*sin(wave.age*18.0))))
  draw_colored_polygon(crest,Color("7430cc"))
  draw_polyline(crest,Color("291044"),12.0,true)
  draw_polyline(crest,Color("c15cff"),7.0,true)
  draw_polyline(crest,Color("f6daff"),2.0,true)
  for trail in 3:
   var x:float=local_x-wave.direction*(28.0+trail*13.0)
   draw_line(Vector2(x,-6),Vector2(x-wave.direction*9,-15-trail*3),Color(0.77,0.4,1.0,0.75-trail*0.15),3,true)
 if impact_age<0.5:
  var fade:=1.0-impact_age/0.5
  draw_set_transform(Vector2(0,-3),0,Vector2(1,0.25))
  draw_arc(Vector2.ZERO,50+impact_age*235,0,TAU,40,Color(0.79,0.43,1.0,fade),5,true)
  draw_set_transform(Vector2.ZERO)
  for i in 8:
   var side:float=-1.0 if i%2==0 else 1.0
   var spark:=Vector2(side*(30.0+impact_age*(90.0+i*13.0)),-sin(impact_age/0.5*PI)*(20.0+i*4.0))
   draw_circle(spark,3.0*fade,Color(0.9,0.67,1.0,fade))
 if state == "stomp_warn":
  var radius := lerpf(25.0, 85.0, clampf(timer / warning_duration, 0, 1))
  draw_arc(Vector2.ZERO, radius, PI, TAU, 22, Color("ce7dff"), 4, true)
  for sign_x in [-1, 1]:
   draw_line(Vector2(sign_x * 92, -8), Vector2(sign_x * 112, -8), Color("ead1ff"), 4, true)
   draw_line(Vector2(sign_x * 112, -8), Vector2(sign_x * 105, -16), Color("ead1ff"), 4, true)
 if state=="rest":
  for i in 3:
   var a:=timer*4+i*TAU/3
   draw_texture_rect(DreamArt.texture("star"),Rect2(cos(a)*45-10,-165+sin(a)*9,22,22),false)
 if state=="warn":
  draw_circle(Vector2(0,-172),12,Color("ffdc6d"))
  draw_line(Vector2(0,-178),Vector2(0,-171),Color("5e4531"),3)
  draw_circle(Vector2(0,-166),1.8,Color("5e4531"))

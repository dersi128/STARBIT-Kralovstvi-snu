@tool
extends Node2D
@export var number := 1
@export var title := "První stezka"
@export var spawn := Vector2(140,550)
@export var width := 4000.0
@export var camera_top := -2400
@export var camera_bottom := 2400
@export var fall_limit := 2700.0
@export var fouk_at_start := false
var arena_active:=false
var arena_walls:Array[StaticBody2D]=[]
var arena_floor:=550.0
var checkpoint := Vector2.ZERO
var player: CharacterBody2D
var boss_alive := false
var star_collected := false
func _ready() -> void:
 if Engine.is_editor_hint():return
 if get_parent()==get_tree().root:
  var game=load("res://Main.tscn").instantiate()
  game.preview_number=number
  game.preview_scene_path=scene_file_path
  get_tree().root.add_child.call_deferred(game)
  queue_free()
  return
 add_to_group("level")
 checkpoint=spawn
 boss_alive=has_node("Boss")
 var scene:PackedScene=load("res://scenes/Bit.tscn")
 player=scene.instantiate();player.position=spawn;player.has_fouk=fouk_at_start;add_child(player)
 var camera:=Camera2D.new();camera.name="Camera2D";camera.set_script(preload("res://scripts/follow_camera.gd"))
 camera.limit_left=0;camera.limit_right=int(width);camera.limit_top=camera_top;camera.limit_bottom=camera_bottom
 camera.position_smoothing_enabled=false
 player.add_child(camera)
 var boss=get_node_or_null("Boss")
 if boss:
  arena_floor=boss.position.y
  for x in [boss.left-130,boss.right+130]:
   var wall:=StaticBody2D.new();wall.position=Vector2(x,arena_floor-650);wall.collision_layer=0;wall.collision_mask=0
   var shape:=CollisionShape2D.new();var rect:=RectangleShape2D.new();rect.size=Vector2(30,1500);shape.shape=rect;wall.add_child(shape)
   add_child(wall);arena_walls.append(wall)
func set_checkpoint(point:Vector2) -> void:
 checkpoint=point
func respawn_player() -> void:
 _set_arena(false)
 player.global_position=checkpoint+Vector2(0,-5)
 player.velocity=Vector2.ZERO
 player.boost_used=false
 player.frozen=false
 player.get_node("Camera2D").reset_follow()
 var boss=get_node_or_null("Boss")
 if boss and not boss.defeated:
  boss.reset_encounter()

func check_portal_contact(previous:Vector2,current:Vector2) -> bool:
 if not star_collected or boss_alive:return false
 if number==3 and not player.has_fouk:return false
 for object in get_tree().get_nodes_in_group("objects"):
  if object.kind=="goal" and object.touches_portal(previous,current):
   get_tree().call_group("game","enter_portal")
   return true
 return false
func _set_arena(active:bool) -> void:
 arena_active=active
 for wall in arena_walls:wall.collision_layer=1 if active else 0
 queue_redraw()
func _physics_process(_delta:float) -> void:
 if Engine.is_editor_hint() or player==null:return
 var boss=get_node_or_null("Boss")
 if boss==null:return
 if boss.defeated:
  if arena_active:_set_arena(false)
 elif not arena_active and player.position.x>=boss.left-60 and player.position.x<=boss.right+100:
  _set_arena(true)
 if arena_active:
  # Physical walls plus a boundary guard also stop boosted/high jumps escaping.
  player.position.x=clampf(player.position.x,boss.left-94,boss.right+94)
func _draw() -> void:
 if not arena_active:return
 for wall in arena_walls:
  var x:=wall.position.x
  draw_rect(Rect2(x-15,arena_floor-420,30,420),Color(0.36,0.18,0.6,0.45))
  for y in range(0,420,42):draw_circle(Vector2(x,arena_floor-y),7,Color(0.75,0.5,1,0.8))

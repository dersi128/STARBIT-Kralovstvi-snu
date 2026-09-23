@tool
extends CharacterBody2D
@export var push_speed:=110.0
var origin:=Vector2.ZERO
func _ready() -> void:
 origin=position
 if not Engine.is_editor_hint():add_to_group("push_crates")
func _physics_process(delta:float) -> void:
 if Engine.is_editor_hint():return
 velocity=Vector2(0,minf(velocity.y+1450*delta,900))
 move_and_slide()
 var level=get_tree().get_first_node_in_group("level")
 if level and global_position.y>level.fall_limit:
  position=origin;velocity=Vector2.ZERO
func push(axis:float,delta:float) -> float:
 if not is_on_floor():return 0.0
 var old_x:=position.x
 move_and_collide(Vector2(signf(axis)*push_speed*delta,0))
 return position.x-old_x

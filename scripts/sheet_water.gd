@tool
extends Sprite2D
## Decorative supplied water. Pauses with the level and never changes collisions.
var elapsed:=0.0
func _ready() -> void:
 var mat:=ShaderMaterial.new()
 mat.shader=preload("res://assets/supplied/water_motion.gdshader")
 material=mat
func _process(delta:float) -> void:
 if Engine.is_editor_hint():return
 elapsed+=delta
 material.set_shader_parameter("elapsed",elapsed)

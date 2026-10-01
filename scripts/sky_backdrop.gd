@tool
extends CanvasLayer
## A single slowly panning landscape: no mirrored castle seams or foreground veil.
@export var landscape:Texture2D
var picture:TextureRect
func _ready() -> void:
	layer=-100
	picture=TextureRect.new()
	picture.texture=landscape
	picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(picture)
	_update_view()
func _process(_delta:float) -> void:
	_update_view()
func _update_view() -> void:
	if not is_instance_valid(picture):return
	var viewport_size:=get_viewport().get_visible_rect().size
	picture.size=viewport_size*1.12
	var progress:=0.5
	var height:=0.5
	var camera:=get_viewport().get_camera_2d()
	if camera and not Engine.is_editor_hint():
		var level:=get_parent()
		progress=clampf(camera.global_position.x/maxf(float(level.get("width")),1),0,1)
		height=clampf((camera.global_position.y+600)/1600,0,1)
	picture.position=-viewport_size*0.12*Vector2(progress,height)

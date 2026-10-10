@tool
extends CanvasLayer
## Four quiet landscapes, each belonging to a different part of Level 8.
## They blend in world space instead of tiling scenery along the route.
const LANDSCAPES = preload("res://assets/environment/castle/courtyard_route/courtyard_backdrops.png")
const REGIONS = [Rect2(0, 0, 836, 470), Rect2(836, 0, 836, 470), Rect2(0, 470, 836, 471), Rect2(836, 470, 836, 471)]
@export var transition_positions := PackedFloat32Array([7500.0, 17000.0, 21500.0])
@export_range(200.0, 1600.0, 50.0) var blend_distance := 600.0

var _landscapes: Array[AtlasTexture] = []
var _base: TextureRect
var _next: TextureRect
var _shown := -1

func _ready() -> void:
	layer = -100
	for region in REGIONS:
		var texture := AtlasTexture.new()
		texture.atlas = LANDSCAPES
		texture.region = region
		texture.filter_clip = true
		_landscapes.append(texture)
	_base = _make_picture()
	_next = _make_picture()
	_update_view()

func _make_picture() -> TextureRect:
	var picture := TextureRect.new()
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(picture)
	return picture

func _process(_delta: float) -> void:
	_update_view()

func _update_view() -> void:
	if not is_instance_valid(_base):return
	var view := get_viewport().get_visible_rect().size
	var camera := get_viewport().get_camera_2d()
	var camera_point := Vector2.ZERO
	if camera and not Engine.is_editor_hint():camera_point = camera.global_position
	var index := 0
	var blend := 0.0
	for i in mini(transition_positions.size(), _landscapes.size() - 1):
		var begin := transition_positions[i] - blend_distance * 0.5
		if camera_point.x < begin:break
		index = i
		blend = smoothstep(begin, begin + blend_distance, camera_point.x)
		if blend >= 1.0:
			index = i + 1
			blend = 0.0
	if _shown != index:
		_shown = index
		_base.texture = _landscapes[index]
		_next.texture = _landscapes[mini(index + 1, _landscapes.size() - 1)]
	_next.modulate.a = blend
	_next.visible = blend > 0.0
	var pan := Vector2(clampf(camera_point.x / 25200.0, 0, 1), clampf((camera_point.y + 600.0) / 1800.0, 0, 1))
	for picture in [_base, _next]:
		picture.size = view * 1.08
		picture.position = -view * 0.08 * pan

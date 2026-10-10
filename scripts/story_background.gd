@tool
extends CanvasLayer
## One finite landscape, split losslessly into four strips in Higgsfield.
## The complete picture pans gently through the level; it never repeats or mirrors.

@export_range(1, 10, 1) var level_number: int = 1
@export_range(1.0, 1.5, 0.01) var overscan: float = 1.15
@export_range(0.0, 0.2, 0.005) var vertical_parallax: float = 0.035
@export_range(0.0, 1.0, 0.01) var preview_progress: float = 0.0

const IMAGE_SIZE := Vector2(1672.0, 941.0)
const STRIP_WIDTH := 418.0
const PADDING := 2.0
const ART_PATH := "res://assets/environment/backgrounds/story/level_%02d/part_%d.png"

var _strips: Array[Sprite2D] = []
var _loaded_level: int = 0
var _art_rect := Rect2()

func _ready() -> void:
	layer = -100
	process_priority = 100
	for index in range(4):
		var strip := Sprite2D.new()
		strip.name = "Part%d" % index
		strip.centered = false
		strip.region_enabled = true
		strip.region_rect = Rect2(PADDING, PADDING, STRIP_WIDTH, IMAGE_SIZE.y)
		strip.region_filter_clip_enabled = false
		strip.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		add_child(strip)
		_strips.append(strip)
	_load_art()
	_update_layout()

func _process(_delta: float) -> void:
	if _loaded_level != clampi(level_number, 1, 10):
		_load_art()
	_update_layout()

func _load_art() -> void:
	if _strips.size() != 4:
		return
	var stage: int = clampi(level_number, 1, 10)
	var textures: Array[Texture2D] = []
	for index in range(4):
		var path: String = ART_PATH % [stage, index]
		if not ResourceLoader.exists(path):
			return
		var texture := load(path) as Texture2D
		if texture == null:
			return
		textures.append(texture)
	for index in range(4):
		_strips[index].texture = textures[index]
	_loaded_level = stage

func _update_layout() -> void:
	if _strips.size() != 4:
		return
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	if Engine.is_editor_hint():
		view_size = Vector2(1280.0, 720.0)
	if view_size.x <= 0.0 or view_size.y <= 0.0:
		return
	var art_scale: float = maxf(view_size.x / IMAGE_SIZE.x, view_size.y / IMAGE_SIZE.y) * maxf(1.0, overscan)
	var display_size: Vector2 = IMAGE_SIZE * art_scale
	var overflow: Vector2 = (display_size - view_size).max(Vector2.ZERO)
	var progress: float = clampf(preview_progress, 0.0, 1.0)
	var vertical_shift: float = 0.0
	if not Engine.is_editor_hint():
		var camera: Camera2D = get_viewport().get_camera_2d()
		var level: Node = get_parent()
		if camera != null and level != null:
			var center: Vector2 = camera.get_screen_center_position()
			var level_width: Variant = level.get("width")
			var spawn_point: Variant = level.get("spawn")
			var world_view_width: float = view_size.x / maxf(0.001, camera.zoom.x)
			if typeof(level_width) == TYPE_FLOAT or typeof(level_width) == TYPE_INT:
				progress = clampf((center.x - world_view_width * 0.5) / maxf(1.0, float(level_width) - world_view_width), 0.0, 1.0)
			if typeof(spawn_point) == TYPE_VECTOR2:
				vertical_shift = (center.y - spawn_point.y + 60.0) * vertical_parallax
	var image_position := Vector2(-overflow.x * progress, clampf(-overflow.y * 0.5 - vertical_shift, -overflow.y, 0.0))
	for index in range(4):
		_strips[index].position = image_position + Vector2(index * STRIP_WIDTH * art_scale, 0.0)
		_strips[index].scale = Vector2.ONE * art_scale
	_art_rect = Rect2(image_position, display_size)

func get_art_rect() -> Rect2:
	return _art_rect

@tool
extends StaticBody2D

## Origin: middle of the walkable surface. Water and foam are decorative.
@export_range(96.0, 900.0, 1.0) var width := 300.0:
	set(value):
		width = maxf(value, 96.0)
		_refresh_later()
## Distance from the walkable surface to the bottom of the splash, in local pixels.
## 0 preserves the original art length. Changes only the water, never the deck.
@export_range(0.0, 2400.0, 1.0, "or_greater", "suffix:px") var waterfall_length := 0.0:
	set(value):
		waterfall_length = maxf(value, 0.0)
		_refresh_later()
## Remove the dark fringe caused by the original black image background.
@export_range(0.0, 1.0, 0.05) var edge_cleanup := 1.0:
	set(value):
		edge_cleanup = clampf(value, 0.0, 1.0)
		_refresh_later()
@export_range(0.2, 3.0, 0.1) var animation_speed := 1.0:
	set(value):
		animation_speed = maxf(value, 0.2)
		_refresh_later()
@export_range(0.0, 0.79, 0.01) var phase_offset := 0.0
@export var preview_in_editor := false:
	set(value):
		preview_in_editor = value
		_refresh_later()
## Original artwork calibration; retained for compatibility with existing scenes.
@export var puddle_y := 480.0:
	set(value):
		puddle_y = maxf(value, 160.0)
		_refresh_later()

const CANVAS_WIDTH := 384.0
const WALK_LINE := 94.0
const WATERFALL_SHADER := preload("res://shaders/adjustable_waterfall.gdshader")
var _render: Polygon2D
var _material: ShaderMaterial
var _sync_pending := false

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	add_to_group("animated_water_platforms")
	_sync()
	var visual := get_node("Visual") as AnimatedSprite2D
	visual.frame = int(phase_offset * 10.0) % 8
	_frame_changed()

func _refresh_later() -> void:
	if is_inside_tree() and not _sync_pending:
		_sync_pending = true
		call_deferred("_sync")

func _sync() -> void:
	_sync_pending = false
	var visual := get_node_or_null("Visual") as AnimatedSprite2D
	var collider := get_node_or_null("Deck") as CollisionShape2D
	if visual == null or collider == null:
		return
	if not is_instance_valid(_render):
		_render = get_node_or_null("WaterfallRender") as Polygon2D
		if _render == null:
			_render = Polygon2D.new()
			_render.name = "WaterfallRender"
			add_child(_render, false, Node.INTERNAL_MODE_BACK)
		_material = ShaderMaterial.new()
		_material.shader = WATERFALL_SHADER
		_render.material = _material
	if not visual.frame_changed.is_connected(_frame_changed):
		visual.frame_changed.connect(_frame_changed)
	var ratio := width / CANVAS_WIDTH
	visual.position = Vector2(-width * 0.5, -WALK_LINE * ratio)
	visual.scale = Vector2.ONE * ratio
	visual.speed_scale = animation_speed
	# Keep the original animation clock; the actual polygon bounds contain the
	# entire adjustable fall, avoiding shader-only stretching and wrong culling.
	visual.visible = false
	_render.position = visual.position
	_render.scale = visual.scale
	var end_y := WALK_LINE + waterfall_drop() / ratio
	var height := maxf(512.0, end_y + 64.0)
	_render.polygon = PackedVector2Array([Vector2.ZERO, Vector2(CANVAS_WIDTH, 0), Vector2(CANVAS_WIDTH, height), Vector2(0, height)])
	_material.set_shader_parameter("original_bottom", puddle_y)
	_material.set_shader_parameter("target_bottom", end_y)
	_material.set_shader_parameter("edge_cleanup", edge_cleanup)
	_frame_changed()
	if not Engine.is_editor_hint() or preview_in_editor:
		visual.play(&"flow")
	else:
		visual.pause()
	# Always private, including live duplicates made by the editor.
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(width * 0.80, 16.0)
	collider.shape = rectangle
	collider.position = Vector2(0.0, 8.0)
	collider.one_way_collision = true
	collider.one_way_collision_margin = 6.0

func _frame_changed() -> void:
	if _material == null:
		return
	var visual := get_node("Visual") as AnimatedSprite2D
	if visual.sprite_frames == null or visual.sprite_frames.get_frame_count(visual.animation) == 0:
		return
	var atlas := visual.sprite_frames.get_frame_texture(visual.animation, visual.frame) as AtlasTexture
	if atlas == null:
		return
	_material.set_shader_parameter("source_sheet", atlas.atlas)
	_material.set_shader_parameter("sheet_size", atlas.atlas.get_size())
	_material.set_shader_parameter("frame_origin", atlas.region.position - atlas.margin.position)
	_material.set_shader_parameter("content_rect", Vector4(atlas.margin.position.x, atlas.margin.position.y, atlas.region.size.x, atlas.region.size.y))
	# Existing asset paths identify the variation; old placements need no edits.
	var path := atlas.atlas.resource_path
	var side := path.get_file() == "side.png"
	var ruins := path.get_file() == "ruins.png"
	_material.set_shader_parameter("stream_bounds", Vector2(78, 184) if side else (Vector2(130, 260) if ruins else Vector2(130, 280)))
	var left: Array = [148.0, 148.0, 148.5, 150.5, 148.0, 149.5, 148.0, 149.0]
	var right: Array = [267.0, 266.0, 264.5, 263.5, 266.0, 265.5, 264.0, 264.0]
	if side:
		left = [91.5, 89.0, 89.0, 90.0, 89.0, 87.0, 88.5, 89.5]
		right = [170.0, 169.0, 169.0, 170.0, 169.0, 169.0, 169.5, 171.5]
	elif ruins:
		left = [143.5, 143.0, 144.0, 145.0, 143.0, 144.0, 143.0, 144.0]
		right = [247.0, 248.0, 248.0, 248.0, 247.5, 249.0, 247.0, 249.0]
	_material.set_shader_parameter("stream_core", Vector2(left[visual.frame % 8], right[visual.frame % 8]))
	_material.set_shader_parameter("splash_start", 325.0 if side else (330.0 if ruins else 350.0))

func waterfall_drop() -> float:
	if waterfall_length > 0.0:
		return waterfall_length
	return (puddle_y - WALK_LINE) * width / CANVAS_WIDTH

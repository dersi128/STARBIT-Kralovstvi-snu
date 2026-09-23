@tool
extends Node2D

## Decorative water between banks. No collision, slowdown or damage.
## Origin is the left edge of the average waterline; Depth extends downwards.
@export_range(80.0, 6000.0, 10.0) var width := 600.0:
	set(value):
		width = clampf(value, 80.0, 6000.0)
		_refresh_later()
@export_range(120.0, 3000.0, 10.0) var depth := 400.0:
	set(value):
		depth = clampf(value, 120.0, 3000.0)
		_refresh_later()
@export_range(50.0, 160.0, 5.0) var wave_height := 110.0:
	set(value):
		wave_height = clampf(value, 50.0, 160.0)
		_refresh_later()
@export_range(0.2, 3.0, 0.1) var animation_speed := 1.0
@export_range(0.0, 0.99, 0.01) var phase_offset := 0.0
@export var preview_in_editor := false

const FRAMES: SpriteFrames = preload("res://assets/animations/water_v2/water_frames.tres")
const SURFACE_MATERIAL: Material = preload("res://assets/animations/water_v2/water_material.tres")
var elapsed := 0.0
var current_frame := -1
var tiles: Array[Sprite2D] = []
var rebuild_pending := false

func _ready() -> void:
	add_to_group("animated_water_pools")
	_sync()

func _refresh_later() -> void:
	queue_redraw()
	if is_inside_tree() and not rebuild_pending:
		rebuild_pending = true
		call_deferred("_sync")

func _sync() -> void:
	rebuild_pending = false
	for tile in tiles:
		if is_instance_valid(tile):
			remove_child(tile)
			tile.queue_free()
	tiles.clear()
	var count := maxi(1, ceili(width / 360.0))
	var tile_width := width / float(count)
	var texture := FRAMES.get_frame_texture(&"flow", 0)
	for i in count:
		var tile := Sprite2D.new()
		tile.name = "Surface_%02d" % i
		tile.centered = false
		tile.texture = texture
		tile.material = SURFACE_MATERIAL
		# Mirroring alternating tiles matches the wave height at each seam.
		tile.flip_h = i % 2 == 1
		tile.position = Vector2(i * tile_width, -wave_height * 0.32)
		tile.scale = Vector2(tile_width / texture.get_width(), wave_height / texture.get_height())
		add_child(tile)
		tiles.append(tile)
	current_frame = -1
	_update_frame()
	queue_redraw()

func _process(delta: float) -> void:
	if Engine.is_editor_hint() and not preview_in_editor:
		return
	elapsed += delta * animation_speed
	_update_frame()

func _update_frame() -> void:
	var next_frame := int((elapsed + phase_offset) * 8.0) % 8
	if current_frame == next_frame:
		return
	current_frame = next_frame
	var texture := FRAMES.get_frame_texture(&"flow", current_frame)
	for tile in tiles:
		tile.texture = texture

func _draw() -> void:
	var top := Color(0.015, 0.48, 0.82, 1.0)
	var bottom := Color(0.025, 0.22, 0.40, 1.0)
	draw_polygon(PackedVector2Array([Vector2(0, 12), Vector2(width, 12), Vector2(width, depth), Vector2(0, depth)]), PackedColorArray([top, top, bottom, bottom]))

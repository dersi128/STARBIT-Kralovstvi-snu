@tool
extends Area2D

## Mráček: klid -> varování -> 5 s deště -> uklidnění.
## Origin = underside of the cloud. Rain Height ends at the ground below it.
@export_group("Déšť")
@export_range(100.0, 1200.0, 10.0) var rain_width := 260.0:
	set(value):
		rain_width = clampf(value, 100.0, 1200.0)
		_refresh_later()
@export_range(80.0, 1600.0, 10.0) var rain_height := 270.0:
	set(value):
		rain_height = clampf(value, 80.0, 1600.0)
		_refresh_later()
## 0.20 leaves Bit with 20% of his usual horizontal speed.
@export_range(0.1, 1.0, 0.05) var slow_multiplier := 0.20
@export var active := true:
	set(value):
		if active == value:
			return
		active = value
		phase = &"idle"
		phase_time = 0.0
		_refresh_later()

@export_group("Časování v sekundách")
@export_range(0.5, 20.0, 0.1) var calm_duration := 4.0
@export_range(0.5, 5.0, 0.1) var warning_duration := 1.6
@export_range(0.5, 20.0, 0.1) var rain_duration := 5.0
@export_range(0.5, 5.0, 0.1) var recovery_duration := 1.2
## Offset each copy independently if several clouds share a passage.
@export_range(0.0, 60.0, 0.1) var start_offset := 0.0

const PHASES: Array[StringName] = [&"idle", &"angry", &"rain", &"recover"]
const POSE_SHADER := preload("res://shaders/cloud_pose_blend.gdshader")
const RAIN_SHADER := preload("res://shaders/cloud_rain.gdshader")
const POSE_EDGES := preload("res://scripts/cloud_pose_edges.gd")
const PHASE_BLEND_SECONDS := 0.12
var phase: StringName = &"idle"
var phase_time := 0.0
var rain_time := 0.0
var face: AnimatedSprite2D
var rainfall: AnimatedSprite2D
var cloud_render: Polygon2D
var rain_render: Polygon2D
var pose_material: ShaderMaterial
var rain_material: ShaderMaterial

func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	# Update before Bit, so a phase boundary affects this physics tick.
	process_physics_priority = -10
	add_to_group("rain_clouds")
	face = get_node_or_null("Face") as AnimatedSprite2D
	rainfall = get_node_or_null("Rain") as AnimatedSprite2D
	if face:
		face.pause()
	if rainfall:
		rainfall.pause()
	_create_renderers()
	_sync_geometry()
	if not Engine.is_editor_hint() and active:
		advance_cycle(fposmod(start_offset, cycle_duration()))
	_update_visuals()

func _refresh_later() -> void:
	if is_inside_tree():
		call_deferred("_sync_geometry")
	queue_redraw()

func _create_renderers() -> void:
	# Internal children are rebuilt per instance, so copied clouds do not share
	# material uniforms or save transient render nodes into a level scene.
	if not is_instance_valid(rain_render):
		rain_render = Polygon2D.new()
		rain_render.name = "RainMotion"
		add_child(rain_render, false, Node.INTERNAL_MODE_BACK)
		rain_material = ShaderMaterial.new()
		rain_material.shader = RAIN_SHADER
		rain_render.material = rain_material
	if not is_instance_valid(cloud_render):
		cloud_render = Polygon2D.new()
		cloud_render.name = "CloudMotion"
		add_child(cloud_render, false, Node.INTERNAL_MODE_BACK)
		pose_material = ShaderMaterial.new()
		pose_material.shader = POSE_SHADER
		cloud_render.material = pose_material
	if is_instance_valid(face) and is_instance_valid(rainfall):
		face.visible = false
		rainfall.visible = false
		var texture := face.sprite_frames.get_frame_texture(&"rain", 0) as AtlasTexture
		rain_material.set_shader_parameter("rain_sheet", texture.atlas)
		rain_material.set_shader_parameter("sheet_size", texture.atlas.get_size())

func _set_quad(node: Polygon2D, bounds: Rect2) -> void:
	node.polygon = PackedVector2Array([bounds.position,
		Vector2(bounds.end.x, bounds.position.y), bounds.end,
		Vector2(bounds.position.x, bounds.end.y)])
	node.uv = PackedVector2Array([Vector2.ZERO, Vector2.RIGHT, Vector2.ONE, Vector2.DOWN])

func _sync_geometry() -> void:
	var collision := get_node_or_null("RainArea") as CollisionShape2D
	if collision == null:
		return
	# Shapes are private to each copy. The area stays queryable during all
	# phases; movement_factor gates the effect without deferred physics lag.
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(rain_width, rain_height)
	collision.shape = rectangle
	collision.position = Vector2(0.0, rain_height * 0.5)
	collision.disabled = false
	if is_instance_valid(cloud_render) and is_instance_valid(rain_render):
		var width := rain_width + 40.0
		var height := width * 288.0 / 354.0
		_set_quad(cloud_render, Rect2(-width * 0.5, -height, width, height))
		pose_material.set_shader_parameter("cloud_size", Vector2(width, height))
		_set_quad(rain_render, Rect2(-rain_width * 0.5, -6.0, rain_width, rain_height + 6.0))
		rain_material.set_shader_parameter("rain_size", Vector2(rain_width, rain_height + 6.0))
	_update_visuals()
	queue_redraw()

func movement_factor() -> float:
	if active and phase == &"rain":
		return clampf(slow_multiplier, 0.1, 1.0)
	return 1.0

func cycle_duration() -> float:
	return calm_duration + warning_duration + rain_duration + recovery_duration

func phase_duration() -> float:
	match phase:
		&"angry": return maxf(warning_duration, 0.1)
		&"rain": return maxf(rain_duration, 0.1)
		&"recover": return maxf(recovery_duration, 0.1)
	return maxf(calm_duration, 0.1)

func advance_cycle(delta: float) -> void:
	# The same clock drives the animation and slowdown. No asynchronous timer
	# can leave a stale effect after pause, deletion, restart or teleport.
	phase_time += maxf(delta, 0.0)
	while phase_time + 0.00000001 >= phase_duration():
		phase_time = maxf(phase_time - phase_duration(), 0.0)
		phase = PHASES[(PHASES.find(phase) + 1) % PHASES.size()]

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	rain_time += delta
	if active:
		advance_cycle(delta)
	_update_visuals()

func _pose_at(animation: StringName, elapsed: float, duration: float) -> Vector3:
	# x/y are neighboring frame indices; z is their smooth blend weight.
	var frames := face.sprite_frames
	var count := frames.get_frame_count(animation)
	if animation == &"rain":
		var frame_clock := maxf(elapsed, 0.0) * 10.0
		var index := int(frame_clock) % count
		return Vector3(index, (index + 1) % count, smoothstep(0.0, 1.0, fposmod(frame_clock, 1.0)))
	var total := 0.0
	for i in count:
		total += frames.get_frame_duration(animation, i)
	var cursor := clampf(elapsed / maxf(duration, 0.1), 0.0, 0.999999) * total
	for i in count:
		var weight := frames.get_frame_duration(animation, i)
		if cursor < weight:
			var frame_duration := weight * duration / total
			var blend_duration := minf(0.12, frame_duration * 0.65)
			var remaining := (weight - cursor) * duration / total
			var blend := smoothstep(0.0, 1.0, 1.0 - remaining / maxf(blend_duration, 0.001))
			return Vector3(i, mini(i + 1, count - 1), blend)
		cursor -= weight
	return Vector3(count - 1, count - 1, 0.0)

func _set_pose(slot: String, animation: StringName, index: int) -> void:
	var texture := face.sprite_frames.get_frame_texture(animation, index) as AtlasTexture
	var rect := texture.region
	# 310 is the underside anchor in the original 384 x 352 virtual canvas.
	# Exclude baked rain below the body, keeping four pixels of soft edge.
	rect.size.y = 250.0 if animation == &"rain" else minf(rect.size.y, 314.0 - texture.margin.position.y)
	var size := texture.atlas.get_size()
	pose_material.set_shader_parameter("pose_" + slot, texture.atlas)
	pose_material.set_shader_parameter("rect_" + slot,
		Vector4(rect.position.x / size.x, rect.position.y / size.y, rect.size.x / size.x, rect.size.y / size.y))
	var edge_key := str(animation) + "_" + str(index)
	var edge := PackedFloat32Array()
	if POSE_EDGES.CURVES.has(edge_key):
		edge = PackedFloat32Array(POSE_EDGES.CURVES[edge_key])
	else:
		edge.resize(64)
		edge.fill(1.02)
	pose_material.set_shader_parameter("edge_" + slot, edge)

func _splash_rect(index: int) -> Vector4:
	var texture := face.sprite_frames.get_frame_texture(&"rain_column", index) as AtlasTexture
	var rect := texture.region
	var height := minf(98.0, rect.size.y)
	return Vector4(rect.position.x, rect.end.y - height, rect.size.x, height)

func _update_visuals() -> void:
	if not is_instance_valid(face) or not is_instance_valid(rain_render):
		return
	var current: StringName = phase if active else &"idle"
	var elapsed := phase_time if active else 0.0
	var pose := _pose_at(current, elapsed, phase_duration())
	var next_phase: StringName = PHASES[(PHASES.find(current) + 1) % PHASES.size()]
	var transition := minf(PHASE_BLEND_SECONDS, phase_duration() * 0.4)
	var phase_blend := smoothstep(0.0, 1.0, (elapsed - phase_duration() + transition) / transition) if active else 0.0
	var bob := sin(rain_time * 1.5) * 1.5 if active else 0.0
	cloud_render.position.y = bob
	_set_pose("a", current, int(pose.x))
	_set_pose("b", current, int(pose.y))
	_set_pose("c", next_phase, 0)
	pose_material.set_shader_parameter("frame_mix", pose.z)
	pose_material.set_shader_parameter("phase_mix", phase_blend)
	# Retain the existing scene nodes as frame metadata for old instances.
	face.visible = false
	rainfall.visible = false
	face.animation = current
	face.frame = int(pose.x)
	rainfall.animation = &"rain_column"
	rainfall.frame = face.frame if current == &"rain" else 0
	rain_render.visible = active and current == &"rain" and not Engine.is_editor_hint()
	var envelope := smoothstep(0.0, 0.12, elapsed) * smoothstep(0.0, 0.20, rain_duration - elapsed)
	rain_material.set_shader_parameter("elapsed", elapsed)
	rain_material.set_shader_parameter("opacity", envelope if rain_render.visible else 0.0)
	rain_material.set_shader_parameter("splash_a", _splash_rect(int(pose.x) if current == &"rain" else 0))
	rain_material.set_shader_parameter("splash_b", _splash_rect(int(pose.y) if current == &"rain" else 1))
	rain_material.set_shader_parameter("splash_mix", pose.z if current == &"rain" else 0.0)

func _draw() -> void:
	if Engine.is_editor_hint():
		var area := Rect2(-rain_width * 0.5, 0.0, rain_width, rain_height)
		draw_rect(area, Color(0.30, 0.65, 1.0, 0.06))
		draw_rect(area, Color(0.30, 0.65, 1.0, 0.45), false, 1.0)

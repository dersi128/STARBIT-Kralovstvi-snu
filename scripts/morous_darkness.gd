@tool
extends CanvasLayer
@export_range(0, 1) var strength := 0.15
var clock := 0.0
var safe_lights: Array[Vector3] = []
var ink: Node2D

func _ready() -> void:
	layer = -90
	ink = Node2D.new()
	add_child(ink)
	ink.draw.connect(_draw_darkness)

func add_safe_light(point: Vector2, radius: float) -> void:
	safe_lights.append(Vector3(point.x, point.y, radius))

func _process(delta: float) -> void:
	clock += delta
	if ink != null: ink.queue_redraw()

func _draw_darkness() -> void:
	var view := get_viewport().get_visible_rect().size
	var center := view * 0.5
	var level := get_parent()
	var camera := get_viewport().get_camera_2d()
	var local_strength := strength
	if not Engine.is_editor_hint() and camera != null:
		center = camera.get_screen_center_position()
		local_strength *= lerpf(0.7, 1.0, clampf(center.x / maxf(1, level.width), 0, 1))
	ink.draw_rect(Rect2(Vector2.ZERO, view), Color(0.10, 0.05, 0.22, local_strength * 0.44))
	# Broad, slow wisps flow from the castle on the right. Foreground stays readable.
	for stream in 5:
		var points := PackedVector2Array()
		for index in 45:
			var x := float(index) / 44.0 * (view.x + 160) - 80
			var y := 100.0 + stream * 87.0 + sin(x * 0.006 + clock * 0.28 + stream * 1.4) * 38
			points.append(Vector2(x, y))
		ink.draw_polyline(points, Color(0.19, 0.09, 0.30, local_strength * 0.18), 38 + stream * 5, true)
		ink.draw_polyline(points, Color(0.43, 0.24, 0.55, local_strength * 0.12), 12, true)
	for i in 18:
		var x := fposmod(view.x + i * 127.0 - clock * (16 + i % 4 * 5), view.x)
		var y := 115.0 + fposmod(i * 83.0, view.y * 0.65) + sin(clock + i) * 8
		ink.draw_circle(Vector2(x, y), 2 + i % 3, Color(0.68, 0.45, 0.86, local_strength * 0.42))
	if camera != null:
		for light in safe_lights:
			var position := Vector2(light.x, light.y) - center + view / 2
			for ring in 5:
				ink.draw_circle(position, light.z * (1.0 - ring * 0.15), Color(1, 0.84, 0.39, 0.022))

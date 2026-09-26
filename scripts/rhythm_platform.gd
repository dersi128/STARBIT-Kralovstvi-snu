@tool
extends "res://scripts/dream_platform.gd"
## Rune platform: clear warning, short empty interval, always visible as an outline.
@export var solid_seconds := 3.5
@export var empty_seconds := 1.2
@export var phase_offset := 0.0
var cycle := 0.0
var solid := true

func _physics_process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint():return
	cycle = fposmod(time + phase_offset, solid_seconds + empty_seconds)
	var next := cycle < solid_seconds
	if next != solid:
		solid = next
		$CollisionShape2D.set_deferred("disabled", not solid)
	queue_redraw()

func _draw() -> void:
	if solid or Engine.is_editor_hint():
		draw_frame(0)
		if cycle > solid_seconds - 0.85:
			draw_line(Vector2(4, -3), Vector2(width - 4, -3), Color(1, 0.7, 0.3, 0.55 + sin(time * 15) * 0.3), 5, true)
	else:
		draw_line(Vector2(0, 0), Vector2(width, 0), Color(0.6, 0.88, 1, 0.5), 3, true)
		for i in 4:draw_circle(Vector2(width * (i + 0.5) / 4, 7), 3, Color(0.7, 0.92, 1, 0.5))

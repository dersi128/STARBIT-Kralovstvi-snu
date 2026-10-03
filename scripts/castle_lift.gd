@tool
extends "res://scripts/castle_platform.gd"
## Light powers the balcony. It waits for Bit, carries him up, then returns for another try.
@export var powered := false
@export var return_seconds := 2.0
var extension := 0.0
var travelling := false
var returning := false
var hold := 1.4

func set_powered(value: bool) -> void:
	powered = value
	queue_redraw()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():return
	var rider := false
	var p := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if p != null and p.is_on_floor():
		var feet := to_local(p.global_position)
		rider = feet.x >= -8 and feet.x <= width + 8 and absf(feet.y) < 20
	if powered and rider and not returning:travelling = true
	if returning:
		extension = maxf(0, extension - delta / maxf(return_seconds, 0.5))
		if extension <= 0:
			returning = false
			travelling = false
			hold = 1.4
	elif travelling:
		extension = minf(1, extension + delta / maxf(period, 0.5))
		if extension >= 1:
			if rider:hold = 1.4
			else:hold -= delta
			if hold <= 0:returning = true
	position = origin + travel * smoothstep(0.0, 1.0, extension)
	queue_redraw()

func _draw() -> void:
	super._draw()
	if powered:
		draw_line(Vector2(12, 5), Vector2(width - 12, 5), Color(1, 0.84, 0.34, 0.72), 3, true)
		for x in [width * 0.25, width * 0.75]:draw_circle(Vector2(x, 19), 4, Color(1, 0.92, 0.6, 0.85))

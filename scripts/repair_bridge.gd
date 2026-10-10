@tool
extends StaticBody2D
## Unroll the painted bridge, then enable the full deck; it remains deployed.
@export var width := 740.0
const DECK = preload("res://assets/environment/forest/higgsfield/wood.tres")
var powered := false
var deployed := false
var progress := 0.0
var collider: CollisionShape2D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	collider = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 24)
	collider.shape = shape
	collider.position = Vector2(width * 0.5, 12)
	collider.disabled = true
	add_child(collider)

func set_powered(value: bool) -> void:
	if value:powered = true

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():return
	if powered and not deployed:
		progress = minf(1.0, progress + delta / 1.1)
		# The visible portion is walkable immediately while the bridge unrolls.
		collider.shape.set_deferred("size", Vector2(maxf(4.0, width * progress), 24))
		collider.set_deferred("position", Vector2(width * progress * 0.5, 12))
		collider.set_deferred("disabled", false)
		if progress >= 1.0:
			deployed = true
	queue_redraw()

func _draw() -> void:
	var span := width * progress
	for x in [0.0, width]:
		draw_line(Vector2(x, 25), Vector2(x, -68), Color("604124"), 13, true)
		draw_circle(Vector2(x, -68), 9, Color("b58b44"))
	if span < 2:
		draw_line(Vector2(0, -52), Vector2(65, -10), Color("ac895b"), 5, true)
		return
	var count := maxi(1, ceili(span / 180.0))
	for i in count:
		var piece := minf(180.0, span - i * 180.0)
		draw_texture_rect(DECK, Rect2(i * 180.0, -15, piece + 1, 42), false)
	var rope := PackedVector2Array()
	for i in 33:
		var t := float(i) / 32.0
		rope.append(Vector2(span * t, -53 + sin(t * PI) * 12))
	draw_polyline(rope, Color("c9a674"), 5, true)
	for x in range(36, int(span), 72):
		draw_line(Vector2(x, -50 + sin(x / maxf(span, 1.0) * PI) * 12), Vector2(x, -3), Color("997247"), 3, true)

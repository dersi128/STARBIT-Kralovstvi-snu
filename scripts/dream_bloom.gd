@tool
extends AnimatableBody2D
## Origin is the centre of the open flower's walk line. A rider holds the petals open.
@export_range(100, 280, 5) var width := 205.0
@export var powered := true
@export var rhythmic := false
@export_range(4.0, 12.0, 0.1) var cycle_seconds := 6.5
@export_range(0.0, 1.0, 0.05) var phase := 0.0
@export var flower_texture: Texture2D
@export var closed_flower_texture: Texture2D
## Position of the petal surface inside the cropped flower art, from top to bottom.
@export_range(0, 1, 0.01) var art_walk_line := 0.26
## Split the crown from the rooted stem, so only petals move when a flower closes.
@export_range(0.1, 0.8, 0.01) var petal_split := 0.48
@export_range(0.1, 0.8, 0.01) var closed_petal_split := 0.49
@export var root_drop := 123.0
## Exclude a neighbouring atlas sprite without modifying the supplied image.
@export var open_left_notch := Rect2()
var openness := 1.0
var clock := 0.0
var deck: CollisionShape2D
var warning := false
const FALLBACK = preload("res://assets/world_scenery/Ferns.tres")

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	deck = CollisionShape2D.new()
	deck.name = "PetalDeck"
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 16)
	deck.shape = shape
	deck.position.y = 8
	deck.one_way_collision = true
	deck.one_way_collision_margin = 7
	add_child(deck, false, Node.INTERNAL_MODE_BACK)
	openness = 1.0 if powered else 0.12
	deck.disabled = not powered
	queue_redraw()

func set_powered(value: bool) -> void:
	# A restored flower stays alive for the entire attempt, including checkpoint respawns.
	powered = powered or value

func _has_rider() -> bool:
	for actor in get_tree().get_nodes_in_group("player"):
		var feet: Vector2 = to_local(actor.global_position)
		if absf(feet.x) < width * 0.5 + 25 and feet.y > -26 and feet.y < 22:
			return true
	return false

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	clock += delta
	var cycle := fposmod(clock / maxf(4, cycle_seconds) + phase, 1.0)
	warning = powered and rhythmic and cycle > 0.45 and cycle < 0.64
	var open_now := powered and (not rhythmic or cycle < 0.64 or cycle > 0.89)
	# Closing pauses as soon as someone reaches the petal; never drop a standing child.
	if powered and _has_rider(): open_now = true; warning = false
	openness = move_toward(openness, 1.0 if open_now else 0.12, delta * 1.6)
	deck.set_deferred("disabled", openness < 0.65)
	queue_redraw()

func _draw() -> void:
	var open_amount := 1.0 if Engine.is_editor_hint() and powered else openness
	var tex := flower_texture if flower_texture != null else FALLBACK
	var full_width := width + 30.0
	var full_height := full_width * tex.get_height() / maxf(tex.get_width(), 1)
	var tint := Color.WHITE if powered else Color(0.50, 0.43, 0.64, 0.86)
	if closed_flower_texture != null:
		_draw_rooted_flower(tex, full_width, open_amount, tint)
	else:
		# Existing flowers retain their art placement when no alternate crown is supplied.
		draw_texture_rect(tex, Rect2(-full_width / 2, -full_height * art_walk_line, full_width, full_height), false, tint)
	if powered:
		var edge := Color(1, 0.82, 0.31, 0.7 if warning else 0.23)
		draw_arc(Vector2(0, 9), width * 0.43, PI + 0.12, TAU - 0.12, 28, edge, 2, true)
		for i in 3:
			var age := fposmod(clock * 0.25 + i * 0.33, 1.0)
			draw_circle(Vector2((i - 1) * width * 0.24 + sin(clock + i) * 7, -10 - age * 48), 1.8, Color(1, 0.95, 0.57, sin(age * PI) * 0.65))

func _draw_rooted_flower(tex: Texture2D, full_width: float, open_amount: float, tint: Color) -> void:
	var source_size := tex.get_size()
	var art_scale := full_width / maxf(source_size.x, 1.0)
	var split_y := source_size.y * petal_split
	var crown_top := -source_size.y * art_walk_line * art_scale
	var stem_top := crown_top + split_y * art_scale
	# The split is below the complete petal outline, leaving only stationary foliage.
	# Leaves and roots have one fixed transform. Their bottom meets the existing planter.
	_draw_open_region(tex, Rect2(-full_width / 2, stem_top, full_width, root_drop - stem_top), Rect2(0, split_y, source_size.x, source_size.y - split_y), tint)
	var blend := clampf((open_amount - 0.12) / 0.88, 0.0, 1.0)
	var petal_width := full_width * lerpf(0.62, 1.0, blend)
	if blend > 0.001:
		var open_tint := tint
		open_tint.a *= blend
		_draw_open_region(tex, Rect2(-petal_width / 2, crown_top, petal_width, split_y * art_scale), Rect2(0, 0, source_size.x, split_y), open_tint)
	if blend < 0.999:
		var closed_size := closed_flower_texture.get_size()
		var bud_width := full_width * 0.38
		var bud_source_height := closed_size.y * closed_petal_split
		var bud_height := bud_width * bud_source_height / maxf(closed_size.x, 1.0)
		var bud_tint := tint
		bud_tint.a *= 1.0 - blend
		# A short stem overlap closes the join without shifting the rooted lower plant.
		draw_texture_rect_region(closed_flower_texture, Rect2(-bud_width / 2, stem_top - bud_height, bud_width, bud_height + 3.0), Rect2(0, 0, closed_size.x, bud_source_height), bud_tint)

func _draw_open_region(texture: Texture2D, target: Rect2, source: Rect2, tint: Color) -> void:
	if not open_left_notch.has_area() or source.end.y <= open_left_notch.position.y:
		draw_texture_rect_region(texture, target, source, tint)
		return
	var ratio := target.size / source.size
	var upper_height := maxf(0, open_left_notch.position.y - source.position.y)
	if upper_height > 0:
		draw_texture_rect_region(texture, Rect2(target.position, Vector2(target.size.x, upper_height * ratio.y)), Rect2(source.position, Vector2(source.size.x, upper_height)), tint)
	var lower := Rect2(Vector2(open_left_notch.end.x, source.position.y + upper_height), Vector2(source.end.x - open_left_notch.end.x, source.size.y - upper_height))
	draw_texture_rect_region(texture, Rect2(target.position + (lower.position - source.position) * ratio, lower.size * ratio), lower, tint)

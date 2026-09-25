@tool
extends AnimatableBody2D
## Wooden bridge. Gap coordinates are horizontal pixels from the left end.
const ART = preload("res://assets/worldkit/starbit_bridge_parts.png")
const CLEAN_EDGES = preload("res://shaders/bridge_alpha.gdshader")
const DECK = Rect2(43, 364, 787, 295)
const POST = Rect2(944, 90, 274, 612)
const ROPE = Rect2(146, 963, 78, 55)
const HANGER = Rect2(1050, 775, 64, 405)
const SNAP_OWNER = &"starbit_bridge_snap_owner"
const SNAP_ORIGINAL = &"starbit_bridge_snap_original"
const BANK_LANDING_LENGTH := 8.0

@export var end_offset := Vector2(1186, -270):
	set(value):
		end_offset = Vector2(maxf(value.x, 120.0), value.y)
		_refresh()
@export_range(70.0, 130.0, 1.0) var rail_height := 100.0:
	set(value):
		rail_height = value
		queue_redraw()
@export_range(0.0, 24.0, 1.0) var rope_sag := 13.0:
	set(value):
		rope_sag = value
		queue_redraw()
## Each Vector2 is (start X, end X), in local pixels. Also removes collision.
@export var gaps := PackedVector2Array():
	set(value):
		gaps = value
		_refresh()
@export var broken_ropes := false:
	set(value):
		broken_ropes = value
		queue_redraw()
@export var show_rails := true:
	set(value):
		show_rails = value
		queue_redraw()
@export_flags("Left", "Right") var end_posts := 3:
	set(value):
		end_posts = value
		queue_redraw()

var width: float:
	get:return end_offset.x
var _rider: CharacterBody2D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var clean := ShaderMaterial.new()
	clean.shader = CLEAN_EDGES
	material = clean
	_refresh()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():return
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player == null:
		_restore_snap()
		return
	var point := to_local(player.global_position)
	var surface := end_offset.y * point.x / end_offset.x
	var near_deck := false
	for span in get_solid_spans():
		if point.x >= span.x - 12 and point.x <= span.y + 12:
			near_deck = point.y >= surface - 18 and point.y <= surface + 32
			break
	if not near_deck:
		_restore_snap()
		return
	if _rider != player:
		_restore_snap()
		_rider = player
	# Adjacent bridges transfer ownership without saving the increased value.
	# Only the current owner may restore it when the player leaves the deck.
	if not player.has_meta(SNAP_ORIGINAL):
		player.set_meta(SNAP_ORIGINAL, player.floor_snap_length)
	player.set_meta(SNAP_OWNER, get_instance_id())
	player.floor_snap_length = maxf(float(player.get_meta(SNAP_ORIGINAL)), 8.0)

func _restore_snap() -> void:
	if is_instance_valid(_rider) and _rider.get_meta(SNAP_OWNER, 0) == get_instance_id():
		_rider.floor_snap_length = float(_rider.get_meta(SNAP_ORIGINAL, 1.0))
		_rider.remove_meta(SNAP_OWNER)
		_rider.remove_meta(SNAP_ORIGINAL)
	_rider = null

func _exit_tree() -> void:
	_restore_snap()

func get_solid_spans() -> Array[Vector2]:
	var holes: Array[Vector2] = []
	for gap in gaps:
		var start := clampf(minf(gap.x, gap.y), 0.0, end_offset.x)
		var finish := clampf(maxf(gap.x, gap.y), 0.0, end_offset.x)
		if finish > start:holes.append(Vector2(start, finish))
	holes.sort_custom(func(a: Vector2, b: Vector2) -> bool:return a.x < b.x)
	var spans: Array[Vector2] = []
	var cursor := 0.0
	for gap in holes:
		if gap.x > cursor:spans.append(Vector2(cursor, gap.x))
		cursor = maxf(cursor, gap.y)
	if cursor < end_offset.x:spans.append(Vector2(cursor, end_offset.x))
	return spans

func _deck_point(x: float) -> Vector2:
	return end_offset * (x / end_offset.x)

func _collision_deck_polygon(span: Vector2) -> PackedVector2Array:
	# Banks overlap the bridge by 8 px. Reach the upper bank's height before
	# its vertical edge; otherwise the capsule catches that tiny exposed lip.
	# The landing stays inside each solid span, so broken planks remain holes.
	var inset := minf(BANK_LANDING_LENGTH, end_offset.x * 0.25)
	var slope_start := inset if end_offset.y > 0.0 else 0.0
	var slope_end := end_offset.x - inset if end_offset.y < 0.0 else end_offset.x
	var samples: Array[float] = [span.x]
	for x in [slope_start, slope_end]:
		if x > span.x and x < span.y:
			samples.append(x)
	samples.append(span.y)
	var polygon := PackedVector2Array()
	for x in samples:
		var t := clampf((x - slope_start) / (slope_end - slope_start), 0.0, 1.0)
		polygon.append(Vector2(x, end_offset.y * t))
	var first := polygon[0]
	var last := polygon[polygon.size() - 1]
	polygon.append(last + Vector2(0, 22))
	polygon.append(first + Vector2(0, 22))
	return polygon

func _refresh() -> void:
	queue_redraw()
	if not is_inside_tree():return
	var spans := get_solid_spans()
	var old_shapes: Array[CollisionPolygon2D] = []
	for child in get_children(true):
		if child is CollisionPolygon2D and str(child.name).begins_with("DeckCollision"):
			old_shapes.append(child)
	for i in spans.size():
		var deck: CollisionPolygon2D
		if i < old_shapes.size():
			deck = old_shapes[i]
		else:
			deck = CollisionPolygon2D.new()
			deck.name = "DeckCollision" if i == 0 else "DeckCollision%d" % (i + 1)
			add_child(deck, false, Node.INTERNAL_MODE_BACK)
		deck.polygon = _collision_deck_polygon(spans[i])
		deck.one_way_collision = true
		deck.one_way_collision_margin = 5.0
	for i in range(spans.size(), old_shapes.size()):
		remove_child(old_shapes[i])
		old_shapes[i].queue_free()

func _rope_point(t: float) -> Vector2:
	return end_offset * t + Vector2(0, -rail_height + sin(t * PI) * rope_sag)

func _part(parts: Array[Dictionary], region: Rect2, rect: Rect2, origin := Vector2.ZERO, angle := 0.0, mirrored := false) -> void:
	parts.append({"region":region, "rect":rect, "origin":origin, "angle":angle, "mirrored":mirrored})

func _rope_segment(parts: Array[Dictionary], start: Vector2, finish: Vector2) -> void:
	var span := finish - start
	_part(parts, ROPE, Rect2(-0.4, -5, span.length() + 0.8, 10), start, span.angle())

func _loose_rope(parts: Array[Dictionary], x: float, direction: float) -> void:
	var anchor := _rope_point(x / end_offset.x)
	var previous := anchor
	for i in range(1, 7):
		var t := float(i) / 6.0
		var point := anchor + Vector2(direction * (16.0 * t - 5.0 * t * t), 48.0 * t * t)
		_rope_segment(parts, previous, point)
		previous = point

func get_visual_parts() -> Array[Dictionary]:
	var parts: Array[Dictionary] = []
	var length := end_offset.length()
	var angle := end_offset.angle()
	var spans := get_solid_spans()
	# Clip the regular modules at a missing plank; keep their original scale.
	var boards := maxi(1, ceili(length / 190.0))
	var board_length := length / boards
	var board_x := end_offset.x / boards
	for i in boards:
		for span in spans:
			var start := maxf(span.x, i * board_x)
			var finish := minf(span.y, (i + 1) * board_x)
			if finish <= start:continue
			var fraction := (start - i * board_x) / board_x
			var visible := (finish - start) / board_x
			var region := Rect2(DECK.position + Vector2(DECK.size.x * fraction, 0), Vector2(DECK.size.x * visible, DECK.size.y))
			# Only cover seams within a solid span, never extend into a hole.
			var overlap_left := 0.35 if start > span.x else 0.0
			var overlap_right := 0.35 if finish < span.y else 0.0
			_part(parts, region, Rect2(start * length / end_offset.x - overlap_left, -1, visible * board_length + overlap_left + overlap_right, board_length * DECK.size.y / DECK.size.x), Vector2.ZERO, angle)
	if show_rails:
		# Upright hangers only attach where a plank remains.
		var hangers := maxi(2, ceili(length / 140.0))
		for i in range(1, hangers):
			var t := float(i) / hangers
			for span in spans:
				if t * end_offset.x < span.x + 12 or t * end_offset.x > span.y - 12:continue
				var top := _rope_point(t)
				var height := end_offset.y * t - top.y + 9.0
				_part(parts, HANGER, Rect2(-7, -4, 14, height), top)
				break
		var rail_spans: Array[Vector2] = []
		if broken_ropes:rail_spans = spans
		else:rail_spans.append(Vector2(0, end_offset.x))
		for span in rail_spans:
			var sections := maxi(1, ceili((span.y - span.x) * length / end_offset.x / 14.0))
			for i in sections:
				var start := _rope_point(lerpf(span.x, span.y, float(i) / sections) / end_offset.x)
				var finish := _rope_point(lerpf(span.x, span.y, float(i + 1) / sections) / end_offset.x)
				_rope_segment(parts, start, finish)
			if broken_ropes:
				if span.x > 0:_loose_rope(parts, span.x, -1)
				if span.y < end_offset.x:_loose_rope(parts, span.y, 1)
	# Lanterns face inward; disable posts on small floating deck fragments.
	var post_height := rail_height + 50.0
	var post_scale := post_height / POST.size.y
	var post_rect := Rect2(-86.0 * post_scale, -rail_height - 26.0, POST.size.x * post_scale, post_height)
	if end_posts & 1:_part(parts, POST, post_rect)
	if end_posts & 2:_part(parts, POST, post_rect, end_offset, 0.0, true)
	return parts

func _draw() -> void:
	for part in get_visual_parts():
		draw_set_transform(part.origin, part.angle, Vector2(-1, 1) if part.mirrored else Vector2.ONE)
		draw_texture_rect_region(ART, part.rect, part.region)
	draw_set_transform(Vector2.ZERO)

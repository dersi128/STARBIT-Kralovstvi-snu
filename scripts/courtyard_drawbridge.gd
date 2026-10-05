@tool
extends AnimatableBody2D
## A timed wooden crossing. The pressure plate owns the timer; a completed
## left-to-right crossing secures the bridge for optional exploration.
@export_range(200.0, 1600.0, 10.0) var width := 1000.0:
	set(value):
		width = maxf(value, 200.0)
		if is_inside_tree():_update_deck()
@export_range(0.2, 3.0, 0.1) var deploy_seconds := 0.8
@export_range(0.0, 4.0, 0.1) var warn_seconds := 2.0
## The existing dream_switch supplies its grace value for the warning glow.
@export var power_source: NodePath

const ART = preload("res://assets/worldkit/starbit_bridge_parts.png")
const CLEAN_EDGES = preload("res://shaders/bridge_alpha.gdshader")
const DECK = Rect2(43, 364, 787, 295)
const POST = Rect2(944, 90, 274, 612)
const DECK_DEPTH := 20.0
const MODULE_WIDTH := 180.0

var powered := false
var secured := false
var extension := 0.0
var _collision: CollisionShape2D
var _shape: RectangleShape2D
var _source: Node
var _warning := false
var _glow_time := 0.0
var _entered_from_left := false
var _crossed_middle := false
var _last_player_point := Vector2.ZERO
var _has_last_point := false

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var clean := ShaderMaterial.new()
	clean.shader = CLEAN_EDGES
	material = clean
	_shape = RectangleShape2D.new()
	_collision = CollisionShape2D.new()
	_collision.name = "DeployingDeck"
	_collision.shape = _shape
	_collision.one_way_collision = true
	_collision.one_way_collision_margin = 6.0
	add_child(_collision, false, Node.INTERNAL_MODE_BACK)
	if not power_source.is_empty():_source = get_node_or_null(power_source)
	_update_deck()

func set_powered(value: bool) -> void:
	powered = value

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():return
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	var over_deck := false
	if player:
		var point := to_local(player.global_position)
		# A jumping rider is still on the crossing. Never retract beneath them.
		over_deck = point.x >= -24.0 and point.x <= width + 24.0 and point.y >= -330.0 and point.y <= 60.0
		_track_crossing(point)
	else:
		_entered_from_left = false
		_crossed_middle = false
		_has_last_point = false
	var stay_open := powered or secured or (over_deck and extension > 0.01)
	var previous := extension
	extension = move_toward(extension, 1.0 if stay_open else 0.0, delta / maxf(deploy_seconds, 0.05))
	var was_warning := _warning
	_warning = false
	if powered and not secured and is_instance_valid(_source):
		var remaining: Variant = _source.get("grace")
		_warning = remaining != null and float(remaining) > 0.0 and float(remaining) <= warn_seconds
	_glow_time += delta
	if not is_equal_approx(previous, extension):_update_deck()
	elif _warning or was_warning != _warning:queue_redraw()

func _track_crossing(point: Vector2) -> void:
	if secured:return
	# Teleporting/respawning at the far bank is not a completed crossing.
	if _has_last_point and point.distance_to(_last_player_point) > 120.0:
		_entered_from_left = false
		_crossed_middle = false
	var near_height := point.y >= -330.0 and point.y <= 60.0
	if point.x < -90.0 or not near_height:
		_entered_from_left = false
		_crossed_middle = false
	if extension > 0.01 and point.x >= -65.0 and point.x <= 55.0 and near_height:
		_entered_from_left = true
	if _entered_from_left and point.x >= width * 0.45 and point.x <= width * 0.70:
		_crossed_middle = true
	if _entered_from_left and _crossed_middle and point.x >= width + 12.0 and near_height:
		secured = true
		queue_redraw()
	_last_player_point = point
	_has_last_point = true

func _update_deck() -> void:
	if not is_instance_valid(_collision):return
	var visible_width := width if Engine.is_editor_hint() else width * extension
	_shape.size = Vector2(maxf(visible_width, 0.1), DECK_DEPTH)
	_collision.position = Vector2(visible_width * 0.5, DECK_DEPTH * 0.5)
	_collision.disabled = visible_width < 1.0
	queue_redraw()

func _draw() -> void:
	var visible_width := width if Engine.is_editor_hint() else width * extension
	# Fixed-scale sections reveal from left to right; neither art nor collision
	# stretches a single huge plank across the moat.
	var modules := ceili(visible_width / MODULE_WIDTH)
	for i in modules:
		var start := float(i) * MODULE_WIDTH
		var length := minf(MODULE_WIDTH, visible_width - start)
		var region := Rect2(DECK.position, Vector2(DECK.size.x * length / MODULE_WIDTH, DECK.size.y))
		draw_texture_rect_region(ART, Rect2(start, -1, length + 0.3, MODULE_WIDTH * DECK.size.y / DECK.size.x), region)
	if _warning and visible_width > 0.0:
		var alpha := 0.20 + 0.17 * (0.5 + 0.5 * sin(_glow_time * 5.0))
		draw_line(Vector2(0, 3), Vector2(visible_width, 3), Color(1.0, 0.79, 0.24, alpha), 5.0, true)
	# Small permanent bank posts give the mechanism a home in the courtyard.
	var scale_factor := 112.0 / POST.size.y
	var post_size := POST.size * scale_factor
	draw_texture_rect_region(ART, Rect2(Vector2(-post_size.x * 0.45, -89), post_size), POST)
	draw_texture_rect_region(ART, Rect2(Vector2(width - post_size.x * 0.45, -89), post_size), POST)
	if secured:
		draw_circle(Vector2(10, 9), 4.0, Color(0.55, 0.94, 0.65, 0.8))
		draw_circle(Vector2(width - 10, 9), 4.0, Color(0.55, 0.94, 0.65, 0.8))

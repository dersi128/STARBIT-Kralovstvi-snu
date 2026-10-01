@tool
extends AnimatableBody2D
## A readable cloud platform. Origin is its left walk-line edge.
@export_range(120, 700, 10) var width := 210.0:
	set(value):
		width=value
		if is_inside_tree():_shape()
		queue_redraw()
@export_enum("steady", "drift", "ferry", "fragile", "pulse", "orbit") var behaviour := "steady":
	set(value):behaviour=value;queue_redraw()
## Drift/ferry: displacement. Orbit: horizontal/vertical radius; sprite stays upright.
@export var travel := Vector2.ZERO
@export_range(2.0, 10.0, 0.1) var period := 4.0
## 0 uses the outward duration; lifts can return faster without teleporting.
@export_range(0.0, 10.0, 0.1) var return_period := 0.0
@export var phase_offset := 0.0
@export var powered := true
@export_range(0.8, 3.0, 0.1) var crumble_seconds := 1.25
@export_range(0.6, 2.0, 0.1) var empty_seconds := 1.0
@export_range(0, 4, 1) var art_variant := 0:
	set(value):art_variant=clampi(value,0,4);queue_redraw()
const CLOUDS = [preload("res://assets/cloud_paths/cloud_1.png"), preload("res://assets/cloud_paths/cloud_2.png"), preload("res://assets/cloud_paths/cloud_3.png"), preload("res://assets/cloud_paths/cloud_4.png"), preload("res://assets/cloud_paths/cloud_5.png")]
# Atlas regions discard empty margins without modifying the supplied images.
const REGIONS = [Rect2(145,465,970,395),Rect2(225,388,1000,440),Rect2(180,350,1165,470),Rect2(18,245,1638,560),Rect2(15,248,1887,390)]
var escape_hold := false
var settle_left := 0.0
var settle_from := Vector2.ZERO
var origin := Vector2.ZERO
var clock := 0.0
var solid := true
var countdown := -1.0
var absent := false
var ferry_state := "wait"
var ferry_progress := 0.0
var hold_time := 0.0
var player: CharacterBody2D
var last_deaths := -1
var collision: CollisionShape2D
var visual_alpha := 1.0

func _ready() -> void:
	origin=position
	collision_layer=1;collision_mask=0
	_shape()
	_set_solid(powered)
	visual_alpha=1.0 if powered else 0.17
	if not Engine.is_editor_hint():add_to_group("cloud_steps")

func _shape() -> void:
	collision=get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision==null:
		collision=CollisionShape2D.new();collision.name="CollisionShape2D";add_child(collision)
	var shape:=RectangleShape2D.new()
	shape.size=Vector2(width-20,18)
	collision.shape=shape;collision.position=Vector2(width/2,9)
	collision.one_way_collision=true;collision.one_way_collision_margin=8.0

func set_powered(value:bool) -> void:
	powered=value
	_set_solid(value and not absent)
	queue_redraw()

func _set_solid(value:bool) -> void:
	solid=value
	if is_instance_valid(collision):collision.set_deferred("disabled",not value)

func has_rider() -> bool:
	if not is_instance_valid(player) or not player.is_on_floor():return false
	for i in player.get_slide_collision_count():
		var contact:=player.get_slide_collision(i)
		if contact.get_collider()==self and contact.get_normal().y < -0.5:return true
	return false

func configure_wind(destination:Vector2) -> void:
	settle_from=position
	settle_left=0.65
	behaviour="ferry";travel=destination;powered=true
	clock=0;ferry_state="wait";ferry_progress=0;hold_time=0
	_set_solid(true);queue_redraw()

func begin_collapse(delay:float) -> void:
	escape_hold=true;countdown=delay;absent=false
	_set_solid(true)

func reset_motion() -> void:
	escape_hold=false;settle_left=0
	clock=0;countdown=-1;absent=false
	ferry_state="wait";ferry_progress=0;hold_time=0
	position=origin
	_set_solid(powered)

func _physics_process(delta:float) -> void:
	if Engine.is_editor_hint():return
	if not is_instance_valid(player):player=get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player:
		if last_deaths>=0 and player.deaths!=last_deaths:reset_motion()
		last_deaths=player.deaths
	if settle_left>0:
		settle_left=maxf(0,settle_left-delta)
		position=settle_from.lerp(origin,smoothstep(0,1,1-settle_left/0.65))
		return
	clock+=delta
	if not powered:return
	match behaviour:
		"drift":
			position=origin+travel*(0.5-0.5*cos(TAU*(clock+phase_offset)/period))
		"orbit":
			var angle:=TAU*(clock+phase_offset)/period
			position=origin+Vector2(sin(angle)*travel.x,(1.0-cos(angle))*travel.y)
		"ferry":
			var rider:=has_rider()
			match ferry_state:
				"wait":
					if rider:ferry_state="out"
				"out":
					ferry_progress=minf(1,ferry_progress+delta/period)
					if ferry_progress>=1:ferry_state="hold";hold_time=0
				"hold":
					hold_time=0.0 if rider else hold_time+delta
					if hold_time>1.0:ferry_state="back"
				"back":
					ferry_progress=maxf(0,ferry_progress-delta/(return_period if return_period>0 else period))
					if ferry_progress<=0:ferry_state="wait"
			position=origin+travel*smoothstep(0,1,ferry_progress)
		"fragile":
			if absent and escape_hold:return
			if countdown<0:
				if has_rider():countdown=crumble_seconds
			else:
				countdown-=delta
				if countdown<=0:
					absent=not absent
					countdown=2.4 if absent else -1.0
					_set_solid(not absent)
		"pulse":
			var next:=fposmod(clock+phase_offset,period+empty_seconds)<period
			if next!=solid:_set_solid(next)
	if behaviour in ["fragile","pulse"]:queue_redraw()

func _draw() -> void:
	var tint:=Color.WHITE
	if behaviour in ["drift","ferry","orbit"]:tint=Color("b7ecff")
	elif behaviour=="fragile":tint=Color("ffe3b3")
	elif behaviour=="pulse":tint=Color("ffbde4")
	tint.a=visual_alpha if not Engine.is_editor_hint() else (1.0 if powered else 0.17)
	var region:Rect2=REGIONS[art_variant]
	var art_width:=width+20.0
	var art_scale:=art_width/region.size.x
	# Keep the original proportions; the upper cloud shelf follows the walk line.
	var top:float=[12.0,14.0,12.0,16.0,10.0][art_variant]
	draw_texture_rect_region(CLOUDS[art_variant],Rect2(-10,-top,art_width,region.size.y*art_scale),region,tint)
	if Engine.is_editor_hint() and behaviour=="orbit":
		var points:=PackedVector2Array()
		for i in 49:
			var angle:=TAU*i/48.0
			points.append(Vector2(width/2+sin(angle)*travel.x,(1-cos(angle))*travel.y))
		draw_polyline(points,Color(0.2,0.8,1,0.5),2)
	elif Engine.is_editor_hint() and travel.length()>0:
		draw_line(Vector2(width/2,0),Vector2(width/2,0)+travel,Color(0.2,0.8,1,0.5),2)

func _process(delta:float) -> void:
	if Engine.is_editor_hint():return
	var warning:=behaviour=="fragile" and countdown>=0 and not absent
	if behaviour=="pulse":warning=solid and fposmod(clock+phase_offset,period+empty_seconds)>period-0.8
	var target_alpha:=1.0 if powered and solid else 0.17
	if warning:target_alpha=0.8+0.2*sin(clock*10.0)
	# Fade the drawing independently; never wobble the collision or the rider.
	visual_alpha=move_toward(visual_alpha,target_alpha,delta*4.5)
	queue_redraw()

@tool
extends AnimatableBody2D
## Only used by levels 6–7. Art keeps its proportions and its grassy walk line.
@export var width := 570.0:
	set(value):width=maxf(value,120);queue_redraw();_refresh_water()
@export var depth := 95.0
## Automatic styles apply only to selected existing islands in levels 6–7.
## Explicit choices also work on renamed/copied islands.
@export_enum("Automatic", "Original island", "Left waterfall", "Center waterfall") var waterfall_art := 0:
	set(value):waterfall_art=value;queue_redraw();_refresh_water()
@export_range(0.0, 2400.0, 10.0, "or_greater", "suffix:px") var waterfall_length := 0.0:
	set(value):waterfall_length=maxf(value,0.0);_refresh_water()
@export_range(0.0, 2.0, 0.05) var waterfall_speed := 1.0:
	set(value):waterfall_speed=value;_refresh_water()
@export_range(0.0, 1.0, 0.05) var waterfall_effects := 0.7:
	set(value):waterfall_effects=value;_refresh_water()
@export var preview_waterfall := false:
	set(value):preview_waterfall=value;_refresh_water()
const ART = preload("res://assets/pieces/island.png")
const WATER_ART = preload("res://scripts/sky_waterfall_art.gd")
const AUTO_WATER = {"DryPavilion":0, "OrchardLanding":1, "LastRest":0,
	"WaterfallShelter":1, "HighBellBalcony":0, "QuietGarden":1}
var _water_art: Node2D
var _water_pending := false
func _ready() -> void:
	collision_layer=1
	collision_mask=0
	_sync_water()
	if not renamed.is_connected(_refresh_water):renamed.connect(_refresh_water)
func _water_variant() -> int:
	if waterfall_art==1:return -1
	if waterfall_art>=2:return waterfall_art-2
	return int(AUTO_WATER.get(String(name),-1))
func _refresh_water() -> void:
	if is_inside_tree() and not _water_pending:
		_water_pending=true;call_deferred("_sync_water")
func _sync_water() -> void:
	_water_pending=false
	var variant:=_water_variant()
	if variant<0:
		if is_instance_valid(_water_art):_water_art.visible=false
		queue_redraw();return
	if not is_instance_valid(_water_art):
		_water_art=WATER_ART.new();_water_art.name="SkyWaterfallArt"
		add_child(_water_art,false,Node.INTERNAL_MODE_BACK)
	_water_art.visible=true
	_water_art.configure(width,variant,waterfall_length,waterfall_speed,waterfall_effects,preview_waterfall)
	queue_redraw()
func _draw() -> void:
	if _water_variant()>=0:return
	var scale_factor:float=(width+36)/282.0
	# Exclude the stray fragment along the bottom of the original atlas piece.
	draw_texture_rect_region(ART,Rect2(-18,-34*scale_factor,282*scale_factor,145*scale_factor),Rect2(8,0,282,145))

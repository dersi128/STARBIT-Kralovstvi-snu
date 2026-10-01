@tool
extends "res://scripts/cloud_step.gd"
## Existing waterfall art on the exact original cloud collision and walk line.
@export_enum("garden", "ruins", "side") var waterfall_style:="garden":
	set(value):
		waterfall_style=value
		if is_inside_tree():call_deferred("_rebuild_water")
@export_range(160,1200,10) var waterfall_length:=420.0:
	set(value):
		waterfall_length=value
		if is_instance_valid(water_art):water_art.waterfall_length=value
@export var water_mirrored:=false:
	set(value):
		water_mirrored=value
		if is_instance_valid(water_art):water_art.scale.x=-1 if value else 1
const WATER_SCENES={
	"garden":preload("res://scenes/animated_water/WaterfallGarden.tscn"),
	"ruins":preload("res://scenes/animated_water/WaterfallRuins.tscn"),
	"side":preload("res://scenes/animated_water/WaterfallSide.tscn")}
var water_art:Node2D
var art_width:=-1.0
func _ready() -> void:
	super._ready()
	_rebuild_water()
func _rebuild_water() -> void:
	if is_instance_valid(water_art):
		water_art.visible=false;water_art.queue_free()
	water_art=WATER_SCENES[waterfall_style].instantiate()
	water_art.name="WaterfallArt"
	water_art.width=(width-20.0)/0.8
	water_art.waterfall_length=waterfall_length
	water_art.animation_speed=0.85
	water_art.phase_offset=fposmod(position.x*0.001,0.79)
	water_art.position=Vector2(width/2.0,0)
	water_art.scale.x=-1 if water_mirrored else 1
	water_art.z_index=-1
	add_child(water_art,false,Node.INTERNAL_MODE_BACK)
	# The parent retains the tested collision. This child supplies only artwork.
	water_art.collision_layer=0;water_art.collision_mask=0
	water_art.get_node("Deck").set_deferred("disabled",true)
	art_width=width
func _process(delta:float) -> void:
	super._process(delta)
	if not is_instance_valid(water_art):return
	if not is_equal_approx(art_width,width):
		art_width=width;water_art.width=(width-20.0)/0.8
		water_art.position.x=width/2.0
	water_art.modulate.a=visual_alpha
func _draw() -> void:
	# Sparse drifting fireflies, not a solid foreground glow over the character.
	for i in 5:
		var phase:=fposmod(clock*0.16+i*0.21,1.0)
		var point:=Vector2(width*(0.15+i*0.175)+sin(clock*0.7+i)*8,-18-phase*70)
		var opacity:=sin(PI*phase)*visual_alpha
		draw_circle(point,5,Color(0.65,0.94,1,opacity*0.08))
		draw_circle(point,1.3,Color(0.85,1,1,opacity*0.75))
		if i%3==0:
			draw_line(point-Vector2(3,0),point+Vector2(3,0),Color(0.8,0.97,1,opacity*0.4),1,true)
			draw_line(point-Vector2(0,3),point+Vector2(0,3),Color(0.8,0.97,1,opacity*0.4),1,true)

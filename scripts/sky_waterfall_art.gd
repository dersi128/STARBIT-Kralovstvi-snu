@tool
extends Node2D
## Pure artwork: no body, collision, player code or saved progress.
## The supplied PNG files remain byte-for-byte originals. Their navy matte is
## removed at draw time, and the shader animates only blue/white water pixels.
const LEFT_ART = preload("res://assets/sky_waterfalls/island_left_original.png")
const CENTER_ART = preload("res://assets/sky_waterfalls/island_center_original.png")
const WATER_SHADER = preload("res://shaders/sky_island_water.gdshader")
var _render: Polygon2D
var _water_material: ShaderMaterial
var _clock := 0.0
var _speed := 1.0
var _effects := 0.7
var _preview := false
var _free_fall := false
var _ratio := 1.0
var _walk_y := 320.0
var _foam := Vector2(557.0,770.0)
var _foam_width := 135.0
var _draw_offset := Vector2.ZERO

func _ready() -> void:
	z_index=-1
	_ensure_render()

func _ensure_render() -> void:
	if is_instance_valid(_render):return
	_render=Polygon2D.new();_render.name="WaterRender"
	_water_material=ShaderMaterial.new();_water_material.shader=WATER_SHADER
	_render.material=_water_material
	add_child(_render,false,Node.INTERNAL_MODE_BACK)

func configure(deck_width:float,variant:int,drop:float,speed:float,effects:float,preview:bool,free_fall:bool=false) -> void:
	_ensure_render()
	_speed=speed;_effects=effects;_preview=preview;_free_fall=free_fall
	var centered:=variant==1
	_walk_y=350.0 if centered else 320.0
	_ratio=(deck_width+24.0)/1572.0
	_draw_offset=Vector2(-12.0-50.0*_ratio,-_walk_y*_ratio)
	var original_bottom:=820.0
	var head:=390.0 if centered else 350.0
	# Length changes affect water only. Keep enough room for a readable splash.
	var bottom:=maxf(head+150.0,_walk_y+drop/_ratio) if drop>0.0 else original_bottom
	var foam_start:=690.0
	var foam_scale:=minf(1.0,(bottom-head)*0.4/(original_bottom-foam_start))
	var target_foam:=bottom-(original_bottom-foam_start)*foam_scale
	_foam=Vector2(860.0 if centered else 557.0,target_foam+80.0*foam_scale)
	_foam_width=155.0 if centered else 135.0
	_render.position=_draw_offset;_render.scale=Vector2.ONE*_ratio
	var canvas_height:=maxf(941.0,bottom+90.0)
	_render.polygon=PackedVector2Array([Vector2.ZERO,Vector2(1672,0),Vector2(1672,canvas_height),Vector2(0,canvas_height)])
	_water_material.set_shader_parameter("source_art",CENTER_ART if centered else LEFT_ART)
	_water_material.set_shader_parameter("stream_bounds",Vector2(735,968) if centered else Vector2(483,639))
	_water_material.set_shader_parameter("spray_bounds",Vector2(596,1080) if centered else Vector2(363,740))
	_water_material.set_shader_parameter("head_y",head)
	_water_material.set_shader_parameter("target_bottom",bottom)
	_water_material.set_shader_parameter("free_fall",free_fall)
	_water_material.set_shader_parameter("matte_color",Vector3(11,17,30)/255.0 if centered else Vector3(12,19,34)/255.0)
	_water_material.set_shader_parameter("effect_strength",effects)
	_water_material.set_shader_parameter("clock",_clock)
	queue_redraw()

func _process(delta:float) -> void:
	if not is_visible_in_tree() or (Engine.is_editor_hint() and not _preview):return
	if _speed<=0.0 or _effects<=0.0:return
	_clock+=delta*_speed
	_water_material.set_shader_parameter("clock",_clock)
	queue_redraw()

func _draw() -> void:
	if _effects<=0.0 or _free_fall:return
	# Small ballistic droplets, with smooth birth/death instead of popping loops.
	for i in 12:
		var age:=fposmod(_clock*0.72+float(i)*0.61803399,1.0)
		var side:=-1.0 if i%2==0 else 1.0
		var flight:=sin(age*PI)
		var point:=_foam+Vector2(side*(18.0+age*_foam_width),-flight*(65.0+float(i%4)*19.0)+age*16.0)
		point=_draw_offset+point*_ratio
		var opacity:=sin(age*PI)*_effects*0.7
		var radius:=maxf(0.65,(2.6+float(i%3)*0.7)*_ratio)
		draw_circle(point,radius*2.5,Color(0.38,0.83,1.0,opacity*0.1))
		draw_circle(point,radius,Color(0.67,0.93,1.0,opacity))
		draw_line(point,point+Vector2(-side*1.0,2.3)*_ratio,Color(0.87,0.98,1.0,opacity),maxf(0.6,_ratio),true)

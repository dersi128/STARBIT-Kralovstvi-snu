@tool
extends Node2D
## Drobná živá dekorace. Zemní prvky stojí v počátku uzlu; závěsy mají počátek nahoře.
## Nemá kolizi ani zvuk, zůstává za hráčem a animuje se pouze v záběru kamery.
@export_enum("Fountain","Bench","Flowers","Bookstand","Chandelier","OwlStatue","Lantern","Banner","Butterflies","Fireflies") var kind := "Flowers":
	set(value):kind=value;queue_redraw()
@export_range(20,220,1,"suffix:px") var height := 100.0:
	set(value):height=value;queue_redraw()
@export var phase := 0.0
@export var mirrored := false:
	set(value):mirrored=value;queue_redraw()
## Obnovená zahrada rozjasní i květiny, motýly a světlušky kolem cesty.
@export_enum("Vždy živé","Sluneční fontána","Měsíční fontána") var growth_source := 0
const ART = preload("res://assets/environment/castle/living/royal_life.tres")
var clock := 0.0
var growth := 1.0
var response := 0.0
var level:Node
var watcher:VisibleOnScreenNotifier2D

func _ready() -> void:
	z_index = -6
	clock = phase
	if Engine.is_editor_hint():
		set_process(false)
		queue_redraw()
		return
	level = get_parent()
	while level != null and not level.has_method("respawn_player"):
		level = level.get_parent()
	growth = _target_growth()
	watcher = VisibleOnScreenNotifier2D.new()
	var rect := _art_rect()
	watcher.rect = rect.grow(150)
	watcher.screen_entered.connect(func():set_process(true))
	watcher.screen_exited.connect(func():set_process(false))
	add_child(watcher)
	set_process(false)
	queue_redraw()

func _target_growth() -> float:
	if growth_source == 0 or not is_instance_valid(level):return 1.0
	if not level.get_script() or not "restored" in level:return 1.0
	return 1.0 if level.restored[growth_source - 1] else 0.0

func _process(delta:float) -> void:
	clock += delta
	growth = move_toward(growth,_target_growth(),delta * 0.7)
	var nearby := false
	if is_instance_valid(level) and is_instance_valid(level.player):
		var offset:Vector2 = level.player.global_position - global_position
		nearby = absf(offset.x) < 165 and absf(offset.y) < 145
	response = move_toward(response,1.0 if nearby else 0.0,delta * 2.2)
	queue_redraw()

func _texture() -> Texture2D:
	return ART.get_frame_texture(StringName(kind),0) if ART.has_animation(StringName(kind)) else null

func _art_rect() -> Rect2:
	var texture := _texture()
	var span := height * texture.get_width() / texture.get_height() if texture != null else height * 2.0
	return Rect2(-span * 0.5,0 if kind in ["Banner","Chandelier"] else -height,span,height)

func _point(rect:Rect2,x:float,y:float) -> Vector2:
	return rect.position + rect.size * Vector2(x,y)

func _glow(at:Vector2,radius:float,color:Color,strength:float) -> void:
	# Three low-opacity discs keep illumination light on mobile GPUs.
	for i in range(3,0,-1):
		draw_circle(at,radius * i / 3.0,Color(color,strength * (4-i) * 0.025))

func _spark(at:Vector2,radius:float,color:Color) -> void:
	draw_line(at - Vector2(radius,0),at + Vector2(radius,0),color,1.2,true)
	draw_line(at - Vector2(0,radius),at + Vector2(0,radius),color,1.2,true)

func _draw() -> void:
	var rect := _art_rect()
	var texture := _texture()
	var ink := Color("8a879e").lerp(Color.WHITE,0.35 + growth * 0.65)
	var turn := sin(clock * 1.15) * 0.018 if kind == "Chandelier" else 0.0
	if kind == "Flowers":turn = sin(clock * 1.6) * 0.012
	var flip := Vector2(-1,1) if mirrored else Vector2.ONE
	draw_set_transform(Vector2.ZERO,turn,flip)
	if texture != null:
		if kind == "Banner":_draw_banner(texture,rect,ink)
		else:draw_texture_rect(texture,rect,false,ink)
	match kind:
		"Fountain":_draw_water(rect)
		"Chandelier":
			for at in [Vector2(0.15,0.40),Vector2(0.5,0.49),Vector2(0.86,0.40)]:
				var flicker := 0.9 + 0.1 * sin(clock * 4 + at.x * 9)
				_glow(_point(rect,at.x,at.y),height * 0.16,Color("ffc85f"),flicker)
		"Lantern":_glow(_point(rect,0.5,0.31),height * 0.32,Color("ffe09b"),0.8 + 0.12 * sin(clock * 2))
		"Bookstand":_draw_book(rect)
		"Flowers":_draw_petals(rect)
		"Butterflies":_draw_butterflies()
		"Fireflies":_draw_fireflies()
		"OwlStatue":
			var shimmer := maxf(0.0,sin(clock * 0.6)) * 0.55
			_spark(_point(rect,0.49,0.81),height * 0.025,Color(1,0.89,0.53,shimmer))
	draw_set_transform(Vector2.ZERO)

func _draw_banner(texture:Texture2D,rect:Rect2,ink:Color) -> void:
	# The mount stays fixed; only the lower fabric moves by a couple of pixels.
	var source_size := texture.get_size()
	for i in range(12):
		var fraction := i / 12.0
		var shift := sin(clock * 1.7 - fraction * 2.0) * pow(fraction,2) * height * 0.016
		var cell := Rect2(rect.position + Vector2(shift,height * fraction),Vector2(rect.size.x,height / 12.0 + 0.4))
		var source := Rect2(0,source_size.y * fraction,source_size.x,source_size.y / 12.0 + 0.3)
		draw_texture_rect_region(texture,cell,source,ink)

func _draw_water(rect:Rect2) -> void:
	# Water alone flows between the two bowls; the fountain masonry is still.
	for side in [-1,1]:
		for drop in range(5):
			var t := fposmod(clock * 0.66 + drop * 0.2 + side * 0.09,1.0)
			var at := _point(rect,0.5 + side * (0.205 + t * 0.01),0.32 + t * 0.29)
			draw_line(at,at + Vector2(side * 0.3,height * 0.022),Color(0.84,0.98,1,0.68),1.6,true)
	for i in range(2):
		var t := fposmod(clock * 0.6 + i * 0.5,1.0)
		draw_set_transform(_point(rect,0.5,0.615),0,Vector2(-1 if mirrored else 1,0.16))
		draw_arc(Vector2.ZERO,rect.size.x * (0.16 + t * 0.23),0,TAU,24,Color(0.77,0.98,1,(1-t)*0.55),1.2,true)
	draw_set_transform(Vector2.ZERO,0,Vector2(-1,1) if mirrored else Vector2.ONE)

func _draw_book(rect:Rect2) -> void:
	for i in range(4):
		var t := fposmod(clock * 0.22 + i * 0.25,1.0)
		var at := _point(rect,0.2 + i * 0.2,0.24 - t * 0.2)
		_spark(at,2.2,Color(0.79,0.90,1,sin(t * PI) * (0.25 + response * 0.55)))

func _draw_petals(rect:Rect2) -> void:
	if growth < 0.05:return
	for i in range(3):
		var t := fposmod(clock * 0.09 + i / 3.0,1.0)
		var at := _point(rect,t,0.22 + 0.13 * sin(clock + i)) - Vector2(0,response * height * 0.24)
		draw_circle(at,1.6,Color(1,0.67,0.81,sin(t * PI) * growth * 0.7))

func _draw_butterflies() -> void:
	for i in range(3):
		var t := clock * (0.43 + i * 0.06) + i * 2.1
		var at := Vector2(sin(t) * height * 0.62,-height * (0.55 + 0.2 * cos(t * 1.3) + response * 0.35))
		var flap := 0.20 + 0.80 * absf(sin(clock * 8 + i))
		var color:Color = [Color("ffc98e"),Color("a4def2"),Color("efa4d9")][i]
		color.a = 0.2 + growth * 0.7
		draw_set_transform(at,0.14 * sin(t),Vector2(flap,1))
		for side in [-1,1]:
			draw_colored_polygon(PackedVector2Array([Vector2.ZERO,Vector2(side*6,-5),Vector2(side*8,-2),Vector2(side*5,3),Vector2(side*2,2)]),color)
		draw_set_transform(at)
		draw_line(Vector2(0,-2),Vector2(0,3),Color(0.36,0.27,0.49,color.a),1.2,true)
	draw_set_transform(Vector2.ZERO)

func _draw_fireflies() -> void:
	for i in range(7):
		var t := clock * 0.28 + i * 1.7
		var at := Vector2(sin(t * 0.9) * height * 0.9,-height * (0.42 + 0.32 * sin(t * 0.7)))
		var strength := (0.25 + growth * 0.75) * (0.3 + 0.7 * maxf(0,sin(clock * 1.3 + i)))
		_glow(at,8,Color("fcdf8d"),strength)
		draw_circle(at,1.8,Color(1,0.9,0.61,strength * 0.8))

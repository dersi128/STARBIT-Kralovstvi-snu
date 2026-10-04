@tool
extends Node2D
## Grounded royal cage. Reuses the palace frame and the original Jiskra art.
const FRAME = preload("res://assets/royal/expansion/level10_atlas.png")
const JISKRA = preload("res://assets/pieces/jiskra.png")
const MESSAGE := "Bite, dokázal jsi to! Temnota mě tu uvěznila. Díky tobě může Království snů zase zářit. Pojďme domů!"
var kind := "jiskra"
var rescued := false
var state := "locked"
var opening := 0.0
var clock := 0.0
var ready_to_unlock := false

func _ready() -> void:
	z_index = 1
	queue_redraw()

func _process(delta:float) -> void:
	if Engine.is_editor_hint():return
	clock += delta
	var level := get_parent()
	var player = level.player
	var boss = level.get_node_or_null("Boss")
	var game = get_tree().get_first_node_in_group("game")
	ready_to_unlock = boss != null and boss.defeated and boss.dialogue_completed and level.star_collected
	if game == null or player == null or game.mode != "play":return
	if state == "locked" and ready_to_unlock and player.is_on_floor():
		var distance:Vector2 = player.global_position - global_position
		if absf(distance.x) < 180.0 and absf(distance.y) < 65.0:
			state = "opening"
			player.frozen = true
			player.velocity = Vector2.ZERO
			player.buffer = 0.0
			Progress.sfx("repair")
	elif state == "opening":
		opening = minf(1.0, opening + delta / 1.8)
		if opening >= 1.0 and game.begin_jiskra_rescue_dialogue(self):
			state = "dialogue"
	queue_redraw()

func finish_rescue() -> void:
	if state != "dialogue" or rescued:return
	rescued = true
	state = "free"
	var level := get_parent()
	level.player.frozen = false
	level.player.buffer = 0.0
	# A fall after the rescue never sends the player back through the final trials.
	level.set_checkpoint(global_position + Vector2(-135, 0))
	Progress.sfx("checkpoint")
	queue_redraw()

func reset_interrupted_rescue() -> void:
	if rescued:return
	state = "locked"
	opening = 0.0
	queue_redraw()

func _star(center:Vector2,radius:float,color:Color) -> void:
	var points := PackedVector2Array()
	for i in range(10):
		var angle := -PI * 0.5 + i * PI / 5.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius * (1.0 if i % 2 == 0 else 0.46))
	draw_colored_polygon(points,color)

func _draw() -> void:
	var lift := smoothstep(0.0, 0.66, opening)
	var emerge := smoothstep(0.42, 1.0, opening)
	var glow := Color("ffdf83") if ready_to_unlock or opening > 0.0 else Color("af86ee")
	# The plinth meets the playable surface exactly at y=0.
	draw_style_box(_plinth(),Rect2(-105,-15,210,15))
	draw_circle(Vector2(0,-75),52,Color(glow,0.11 + sin(clock * 2.0) * 0.025))
	var friend_position := Vector2(112 * emerge, -66 - sin(clock * 2.2) * 2.5)
	draw_texture_rect(JISKRA,Rect2(friend_position + Vector2(-43,-38),Vector2(86,81)),false)
	# Each bar retracts into the crown; the character stays visible between bars.
	if lift < 1.0:
		var bar_bottom := lerpf(-19,-128,lift)
		for x in [-44,-22,0,22,44]:
			draw_line(Vector2(x,-131),Vector2(x,bar_bottom),Color("323758"),8,true)
			draw_line(Vector2(x-1,-131),Vector2(x-1,bar_bottom),Color("c4cee8"),4,true)
			draw_line(Vector2(x-2,-130),Vector2(x-2,bar_bottom),Color("f2eafe"),1.2,true)
		draw_line(Vector2(-52,bar_bottom),Vector2(52,bar_bottom),Color("52628a"),7,true)
		var lock_center := Vector2(0,lerpf(-66,-144,lift))
		draw_circle(lock_center,15,Color("493164"))
		draw_circle(lock_center,12,glow)
		_star(lock_center,8,Color("fff4bc"))
	draw_texture_rect_region(FRAME,Rect2(-109,-241,218,241),Rect2(861,7,374,413))
	for x in [-44,0,44]:_star(Vector2(x,-151),8,glow)
	if opening > 0.0 and opening < 1.0:
		for i in range(12):
			var angle := i * TAU / 12.0 + opening * 1.4
			var at := Vector2(0,-85) + Vector2(cos(angle),sin(angle)) * (24 + opening * 97)
			_star(at,4,Color(1.0,0.9,0.55,sin(opening * PI)))

func _plinth() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("b7d5d5")
	box.border_color = Color("ddb651")
	box.set_border_width_all(3)
	box.set_corner_radius_all(6)
	return box

@tool
extends Node2D
## Bells stay lit after a fall. All three awaken the exit carrier, in any order.
@export var bells:Array[NodePath]=[]
@export var carrier:NodePath
@export var wind_travel:=Vector2(1050,-80)
@export var progress_area:=Rect2(9000,-800,4800,2000)
var active:=false
var count:=0
var completed_age:=0.0
var progress_label:Label
const FONT=preload("res://assets/menu/pause/Nunito.ttf")
func _ready() -> void:
	z_index=2
	if Engine.is_editor_hint():return
	var layer:=CanvasLayer.new();layer.layer=4;add_child(layer)
	progress_label=Label.new();progress_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	progress_label.size=Vector2(760,34);progress_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	progress_label.add_theme_font_override("font",FONT);progress_label.add_theme_font_size_override("font_size",21)
	progress_label.add_theme_color_override("font_color",Color("fff4cb"))
	progress_label.add_theme_color_override("font_outline_color",Color("203e57"));progress_label.add_theme_constant_override("outline_size",5)
	progress_label.visible=false;layer.add_child(progress_label)
func _physics_process(delta:float) -> void:
	if Engine.is_editor_hint():return
	count=0
	for path in bells:
		var bell:=get_node_or_null(path)
		if bell!=null and bell.active:count+=1
	if not active and not bells.is_empty() and count==bells.size():
		active=true
		var ferry:=get_node_or_null(carrier)
		if ferry!=null:ferry.configure_wind(wind_travel)
		Progress.sfx("repair")
	if active:completed_age+=delta
	_update_progress()
	queue_redraw()
func _update_progress() -> void:
	if not is_instance_valid(progress_label):return
	var player:=get_tree().get_first_node_in_group("player") as Node2D
	progress_label.visible=player!=null and progress_area.has_point(player.global_position) and (not active or completed_age<3.0)
	progress_label.position=Vector2((get_viewport().get_visible_rect().size.x-760)/2,56)
	var missing:=PackedStringArray()
	var names:=["dolní", "horní", "pravý"]
	for i in bells.size():
		var bell:=get_node_or_null(bells[i])
		if bell!=null and not bell.active:missing.append(names[i] if i<names.size() else str(i+1))
	progress_label.text="Všechny zvonky zní — cesta je otevřená!" if active else "Zvonky %d/%d · zbývá: %s"%[count,bells.size(),", ".join(missing)]
func _draw() -> void:
	var text:="Proud probuzen" if active else "Světelné zvonky  %d / %d"%[count,bells.size()]
	var extent:=FONT.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,20)
	draw_string_outline(FONT,Vector2(-extent.x/2,-130),text,HORIZONTAL_ALIGNMENT_LEFT,-1,20,5,Color("203e57"))
	draw_string(FONT,Vector2(-extent.x/2,-130),text,HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("fff4cb"))

@tool
extends "res://scripts/level.gd"
@export var objectives: Array[NodePath] = []
@export var objective_caption := "Mlýny"
var objective_label:Label
func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint() or player==null:return
	var layer:=CanvasLayer.new();layer.layer=3;add_child(layer)
	objective_label=Label.new();objective_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	objective_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	objective_label.position=Vector2(300,18);objective_label.size=Vector2(680,34)
	objective_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	objective_label.add_theme_font_override("font",preload("res://assets/menu/pause/Nunito.ttf"))
	objective_label.add_theme_font_size_override("font_size",22)
	objective_label.add_theme_color_override("font_color",Color("fff9dc"))
	objective_label.add_theme_color_override("font_outline_color",Color("204456"))
	objective_label.add_theme_constant_override("outline_size",5)
	layer.add_child(objective_label)
func completed_objectives() -> int:
	var completed:=0
	for path in objectives:
		var node:=get_node_or_null(path)
		if node and node.active:completed+=1
	return completed
func _physics_process(delta:float) -> void:
	super._physics_process(delta)
	if is_instance_valid(objective_label):
		objective_label.text="%s  %d/%d"%[objective_caption,completed_objectives(),objectives.size()]
		var view:=get_viewport().get_visible_rect().size
		objective_label.position.x=maxf(180,(view.x-680)/2)
		objective_label.visible=completed_objectives()<objectives.size()
func check_portal_contact(previous:Vector2,current:Vector2) -> bool:
	if completed_objectives()<objectives.size():return false
	return super.check_portal_contact(previous,current)

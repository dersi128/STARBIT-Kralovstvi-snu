@tool
extends "res://scripts/level.gd"
@export var objectives: Array[NodePath] = []
@export var objective_caption := "Mlýny"
var objective_label:Label
var objective_portal:Node2D
func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint() or player==null or objectives.is_empty():return
	for object in get_tree().get_nodes_in_group("objects"):
		if is_ancestor_of(object) and object.kind=="goal":
			objective_portal=object;break
	if objective_portal==null:return
	# A local reminder at the blocked gate replaces the permanent global counter.
	objective_label=Label.new();objective_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	objective_label.size=Vector2(480,38)
	objective_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	objective_label.add_theme_font_override("font",preload("res://assets/menu/pause/Nunito.ttf"))
	objective_label.add_theme_font_size_override("font_size",20)
	objective_label.add_theme_color_override("font_color",Color("fff9dc"))
	objective_label.add_theme_color_override("font_outline_color",Color("204456"))
	objective_label.add_theme_constant_override("outline_size",4)
	objective_label.z_index=20;objective_label.visible=false;add_child(objective_label)
func completed_objectives() -> int:
	var completed:=0
	for path in objectives:
		var node:=get_node_or_null(path)
		if node and node.active:completed+=1
	return completed
func _physics_process(delta:float) -> void:
	super._physics_process(delta)
	if not is_instance_valid(objective_label) or player==null:return
	var distance:=player.global_position-objective_portal.global_position
	objective_label.visible=completed_objectives()<objectives.size() and absf(distance.x)<360 and absf(distance.y)<240
	if not objective_label.visible:return
	objective_label.position=to_local(objective_portal.global_position)+Vector2(-240,-186)
	objective_label.text="Probuď zbývající větrné proudy."
	for path in objectives:
		var node:=get_node_or_null(path)
		if node==null or node.active:continue
		if node.name=="FirstAnchor":objective_label.text="Nejprve obnov větrnou kotvu.";break
		if node.name=="BellChoir":objective_label.text="Rozezvuč zbývající zvonky.";break
func check_portal_contact(previous:Vector2,current:Vector2) -> bool:
	if completed_objectives()<objectives.size():return false
	return super.check_portal_contact(previous,current)

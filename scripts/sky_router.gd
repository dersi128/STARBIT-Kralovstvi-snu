@tool
extends Node
## Select only from a stable island; keep inactive route visible as a faint preview.
@export var upper: Array[NodePath] = []
@export var lower: Array[NodePath] = []
@export var upper_rain: Array[NodePath] = []
@export var lower_rain: Array[NodePath] = []
@export_enum("Horní", "Dolní") var selected := 0
func _ready() -> void:
	if not Engine.is_editor_hint():call_deferred("_apply")
func select_route(index:int) -> void:
	if selected==index:return
	selected=clampi(index,0,1)
	_apply();Progress.sfx("checkpoint")
func _apply() -> void:
	for pair in [[upper,selected==0],[lower,selected==1]]:
		for path in pair[0]:
			var node:=get_node_or_null(path)
			if node:node.set_powered(pair[1])
	for pair in [[upper_rain,selected==1],[lower_rain,selected==0]]:
		for path in pair[0]:
			var node:=get_node_or_null(path)
			if node:node.active=pair[1]

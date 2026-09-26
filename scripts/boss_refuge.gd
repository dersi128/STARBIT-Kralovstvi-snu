@tool
extends "res://scripts/crumble_platform.gd"
## A temporary refuge during the fight, restored for each fresh attempt.
var encounter_over := false

func _physics_process(delta: float) -> void:
 if encounter_over:return
 super(delta)

func reset_for_encounter() -> void:
 encounter_over=false
 countdown=-1.0
 absent=false
 $CollisionShape2D.set_deferred("disabled",false)
 queue_redraw()

func finish_encounter() -> void:
 reset_for_encounter()
 encounter_over=true

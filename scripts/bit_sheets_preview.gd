extends Node2D
# Preview helper only: keeps one-shot animation rows running for inspection.
func _ready() -> void:
 for child in get_children():
  if child is AnimatedSprite2D:
   child.animation_finished.connect(func():
    if not is_instance_valid(child):return
    child.set_frame_and_progress(0,0)
    child.play()
   )
func _unhandled_key_input(event:InputEvent) -> void:
 if event is InputEventKey and event.pressed and event.keycode==KEY_SPACE:
  for child in get_children():
   if child is AnimatedSprite2D:
    child.set_frame_and_progress(0,0);child.play()

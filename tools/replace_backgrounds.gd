@tool
extends EditorScript
## Open this script in Godot and run File > Run (Ctrl+Shift+X).

const INSTALLATION := preload("res://tools/story_background_installation.gd")

func _run() -> void:
	get_editor_interface().save_all_scenes()
	var result: Dictionary = INSTALLATION.install()
	if result.has("error"):
		push_error(str(result["error"]))
		return
	get_editor_interface().get_resource_filesystem().scan()
	print("STARBIT: nová pozadí připravena. Upraveno levelů: %d. Původní levely: %s. Znovu otevři level a spusť F6." % [result["changed"], result["backup"]])

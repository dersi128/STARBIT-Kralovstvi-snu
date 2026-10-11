extends "res://tests/repository_integrity.gd"

func run() -> void:
	var output := OS.get_environment("STARBIT_TEST_OUTPUT")
	if output.is_empty(): quit(2); return
	root.get_node("Progress").save_path = output.path_join("isolated-integrity.cfg")
	await super()

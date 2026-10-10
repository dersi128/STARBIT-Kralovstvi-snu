extends RefCounted
## Changes only legacy background visibility and one new scene reference.
## Every other line of each existing level is preserved.

const SCENE_PATH := "res://scenes/environments/StoryBackground.tscn"
const BACKUP_DIR := "res://background-backup-20261010"
const RESOURCE_ID := "story_background_20261010"
const OLD_BACKGROUNDS := ["DistantForest", "Background", "Backdrop", "Pozadí"]

static func updated_source(source: String, level_number: int) -> String:
	if source.contains('name="StoryBackground" parent="."'):
		return source
	var lines: PackedStringArray = source.split("\n", true)
	var output := PackedStringArray()
	var hiding: bool = false
	var resource_inserted: bool = false
	var step_regex := RegEx.new()
	step_regex.compile("load_steps=(\\d+)")
	for line in lines:
		if line.begins_with("[gd_scene"):
			var found: RegExMatch = step_regex.search(line)
			if found != null:
				line = step_regex.sub(line, "load_steps=%d" % (int(found.get_string(1)) + 1))
			output.append(line)
			output.append('[ext_resource type="PackedScene" path="%s" id="%s"]' % [SCENE_PATH, RESOURCE_ID])
			resource_inserted = true
			continue
		if line.begins_with("["):
			hiding = false
			if line.begins_with("[node ") and line.contains('parent="."'):
				for old_name in OLD_BACKGROUNDS:
					if line.contains('name="%s"' % old_name):
						hiding = true
			output.append(line)
			if hiding:
				output.append("visible = false")
			continue
		if hiding and line.strip_edges().begins_with("visible") and line.contains("="):
			continue
		output.append(line)
	if not resource_inserted:
		return source
	return "\n".join(output).strip_edges() + '\n\n[node name="StoryBackground" parent="." instance=ExtResource("%s")]\nlevel_number = %d\n' % [RESOURCE_ID, level_number]

static func install() -> Dictionary:
	var paths := PackedStringArray()
	var before := PackedStringArray()
	var after := PackedStringArray()
	# Verify all assets and scene paths before changing the first level.
	if not FileAccess.file_exists(SCENE_PATH):
		return {"error": "Chybí scéna StoryBackground.tscn. Rozbal celý balíček do složky hry."}
	for number in range(1, 11):
		var path: String = "res://levels/Level_%02d.tscn" % number
		if not FileAccess.file_exists(path):
			return {"error": "Chybí level: " + path}
		for part in range(4):
			if not FileAccess.file_exists("res://assets/environment/backgrounds/story/level_%02d/part_%d.png" % [number, part]):
				return {"error": "Chybí nový obrázek pro level %d. Rozbal celý balíček." % number}
		paths.append(path)
		var source: String = FileAccess.get_file_as_string(path)
		before.append(source)
		after.append(updated_source(source, number))
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(BACKUP_DIR))
	if directory_error != OK:
		return {"error": "Nelze vytvořit zálohu původních levelů."}
	var ignore := FileAccess.open(BACKUP_DIR + "/.gdignore", FileAccess.WRITE)
	if ignore != null:
		ignore.close()
	for index in range(10):
		if before[index] == after[index]:
			continue
		var backup: String = BACKUP_DIR + "/" + paths[index].get_file()
		if not FileAccess.file_exists(backup):
			var copy_error: Error = DirAccess.copy_absolute(ProjectSettings.globalize_path(paths[index]), ProjectSettings.globalize_path(backup))
			if copy_error != OK:
				return {"error": "Nelze zálohovat " + paths[index]}
	var changed: int = 0
	for index in range(10):
		if before[index] == after[index]:
			continue
		var file := FileAccess.open(paths[index], FileAccess.WRITE)
		if file == null:
			# Restore any files written in this invocation.
			for previous in range(index):
				var restore := FileAccess.open(paths[previous], FileAccess.WRITE)
				if restore != null:
					restore.store_string(before[previous])
					restore.close()
			return {"error": "Nelze uložit " + paths[index]}
		file.store_string(after[index])
		file.close()
		changed += 1
	return {"changed": changed, "backup": BACKUP_DIR}

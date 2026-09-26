extends RefCounted
## Appearance rewards use best level ratings. Stars are milestones, never spent.
const SAVE_PATH := "user://dreambit.cfg"
const COLOR_SHADER = preload("res://shaders/character_palette.gdshader")
const SKINS := {
	"bit": [
		{"id": "original", "title": "Originál", "stars": 0, "color": Color("35d9b3")},
		{"id": "sky", "title": "Nebeský Bit", "stars": 3, "color": Color("459cfa")},
		{"id": "dream", "title": "Fialový sen", "stars": 9, "color": Color("ae72ee")},
		{"id": "sun", "title": "Sluneční Bit", "stars": 15, "color": Color("f7bd45")},
	],
	"fouk": [
		{"id": "original", "title": "Originál", "stars": 0, "color": Color("35d9b3")},
		{"id": "sky", "title": "Modrý vánek", "stars": 5, "color": Color("459cfa")},
		{"id": "dream", "title": "Fialový obláček", "stars": 10, "color": Color("ae72ee")},
		{"id": "sun", "title": "Zlatý Fouk", "stars": 15, "color": Color("f7bd45")},
	],
}

static func skin(character: String, id: String) -> Dictionary:
	for entry in SKINS.get(character, []):
		if entry.id == id:return entry
	return {}

static func is_unlocked(character: String, id: String) -> bool:
	var entry := skin(character, id)
	return not entry.is_empty() and Progress.total_stars() >= int(entry.stars)

static func selected(character: String) -> String:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:return "original"
	var value: Variant = config.get_value("wardrobe", character, "original")
	if value is String and is_unlocked(character, value):return value
	return "original"

static func equip(character: String, id: String) -> Error:
	if not is_unlocked(character, id):return ERR_UNAUTHORIZED
	var config := ConfigFile.new()
	var loaded := config.load(SAVE_PATH)
	if loaded != OK and loaded != ERR_FILE_NOT_FOUND:return loaded
	# Preserve level ratings, audio settings and every other existing save section.
	config.set_value("wardrobe", character, id)
	return config.save(SAVE_PATH)

static func material_for(character: String, id: String) -> ShaderMaterial:
	var entry := skin(character, id)
	if entry.is_empty() or id == "original":return null
	var material := ShaderMaterial.new()
	material.shader = COLOR_SHADER
	var accent: Color = entry.color
	material.set_shader_parameter("target_hue", accent.h)
	material.set_shader_parameter("saturation_scale", accent.s / 0.75)
	return material

static func apply_to(sprite: CanvasItem, character: String) -> void:
	sprite.material = material_for(character, selected(character))

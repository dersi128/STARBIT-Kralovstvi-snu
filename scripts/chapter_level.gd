@tool
extends "res://scripts/level.gd"
## Story objectives for the existing first chapter. Geometry stays in the scenes.
@export var quest_flags: PackedStringArray = []
@export var quest_hints: PackedStringArray = []
@export var final_hint := "Najdi hvězdu a pokračuj k bráně."
@export var zip_departure := false

func objectives_complete() -> bool:
	for flag in quest_flags:
		if not completed_actions.get(flag, false): return false
	return true

func objective_text() -> String:
	if bonus_active:
		return $BonusRoom.objective_text()
	for index in quest_flags.size():
		if not completed_actions.get(quest_flags[index], false):
			return quest_hints[index] if index < quest_hints.size() else "Obnov cestu k hradu."
	if number == 5 and boss_alive: return "Zlom Brúčounovo očarování. Využij chvíli, kdy odpočívá."
	if number == 10:
		if not $JiskraCage.rescued: return "Zámky povolily. Přistup k Jiskře a osvoboď ji."
	return final_hint

func can_finish_level() -> bool:
	if bonus_active or not objectives_complete() or boss_alive: return false
	if number == 10: return $JiskraCage.rescued
	return star_collected

func _physics_process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint() or player == null or bonus_active: return
	if zip_departure and completed_actions.get("wind_gate", false) and player.has_fouk:
		player.has_fouk = false
		player.boost_used = false
		completed_actions["zip_departed"] = true
		var zip := get_node_or_null("ZipAtGate")
		if zip != null: zip.show()
		get_tree().call_group("game", "show_chapter_message", "Zip", "Zůstanu u brány a udržím cestu otevřenou. Ty běž za Jiskrou, Bite!", "fouk")
	if has_node("QuestStar"):
		var ready := objectives_complete()
		$QuestStar.visible = ready
		$QuestStar.process_mode = Node.PROCESS_MODE_INHERIT if ready else Node.PROCESS_MODE_DISABLED

func respawn_player() -> void:
	super()
	if number == 10 and has_node("JiskraCage"):
		$JiskraCage.reset_interrupted_rescue()

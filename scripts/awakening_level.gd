@tool
extends "res://scripts/level.gd"
## The first small service job: recover a gear, repair the winch, lower the bridge.

func can_finish_level() -> bool:
	return star_collected and completed_actions.get("bridge_open", false) and $RepairBridge.deployed

func objective_text() -> String:
	if completed_actions.get("bridge_open", false):
		return "Cesta je volná! Najdi hvězdu a pokračuj za Jiskrou."
	if completed_actions.get("winch_repaired", false):
		return "Naviják funguje. Zatáhni za páku a spusť most."
	if inventory.get("bridge_gear", 0) > 0:
		return "Dones ozubené kolo k rozbitému navijáku."
	if player != null and player.position.x > 1800:
		return "Kolo je nahoře. Pomoz si bednou a seber ho."
	return "Protáhni si klouby a najdi cestu přes potok."

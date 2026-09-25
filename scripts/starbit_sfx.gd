extends RefCounted
## Prepared short effects: no synthesis or disk loading at the moment of a jump.
const EFFECTS := {
	"gold": {"clips": [preload("res://assets/audio/sfx/diamond_01.ogg"), preload("res://assets/audio/sfx/diamond_02.ogg"), preload("res://assets/audio/sfx/diamond_03.ogg")], "db": -10.0, "gap_ms": 40, "voices": 3},
	"jump": {"clips": [preload("res://assets/audio/sfx/jump_01.ogg"), preload("res://assets/audio/sfx/jump_02.ogg")], "db": -9.0, "gap_ms": 45, "voices": 2},
	"boost": {"clips": [preload("res://assets/audio/sfx/boost_01.ogg")], "db": -10.0, "gap_ms": 45, "voices": 2},
	"land": {"clips": [preload("res://assets/audio/sfx/land_01.ogg"), preload("res://assets/audio/sfx/land_02.ogg")], "db": -12.0, "gap_ms": 65, "voices": 2},
	"boss_warn": {"clips": [preload("res://assets/audio/sfx/bear_warn_01.ogg"), preload("res://assets/audio/sfx/bear_warn_02.ogg")], "db": -7.0, "gap_ms": 160, "voices": 1, "priority": true},
	"boss_push": {"clips": [preload("res://assets/audio/sfx/bear_charge_01.ogg"), preload("res://assets/audio/sfx/bear_charge_02.ogg")], "db": -7.0, "gap_ms": 160, "voices": 1, "priority": true},
	"boss_hit": {"clips": [preload("res://assets/audio/sfx/bear_hit_01.ogg"), preload("res://assets/audio/sfx/bear_hit_02.ogg")], "db": -8.0, "gap_ms": 120, "voices": 1, "priority": true},
	"boss_step": {"clips": [preload("res://assets/audio/sfx/bear_step_01.ogg"), preload("res://assets/audio/sfx/bear_step_02.ogg")], "db": -15.0, "gap_ms": 95, "voices": 2},
	"boss_rest": {"clips": [preload("res://assets/audio/sfx/bear_rest_01.ogg")], "db": -11.0, "gap_ms": 180, "voices": 1},
	"boss_free": {"clips": [preload("res://assets/audio/sfx/bear_free_01.ogg")], "db": -8.0, "gap_ms": 500, "voices": 1, "priority": true}
}

extends RefCounted
## Prepared short effects: no synthesis or disk loading at the moment of a jump.
# Boss cues use edited foley and soft air layers; footsteps sit below attack warnings.
const EFFECTS := {
	"boss_stomp": {"clips": [preload("res://assets/audio/sfx/guardian_stomp_01.ogg"), preload("res://assets/audio/sfx/guardian_stomp_02.ogg")], "db": -7.0, "gap_ms": 250, "voices": 1, "priority": true},
	"boss_stomp_warn": {"clips": [preload("res://assets/audio/sfx/guardian_stomp_warn.ogg")], "db": -12.0, "gap_ms": 250, "voices": 1, "priority": true},
	"gold": {"clips": [preload("res://assets/audio/sfx/diamond_01.ogg"), preload("res://assets/audio/sfx/diamond_02.ogg"), preload("res://assets/audio/sfx/diamond_03.ogg")], "db": -10.0, "gap_ms": 40, "voices": 3},
	"jump": {"clips": [preload("res://assets/audio/sfx/jump_01.ogg"), preload("res://assets/audio/sfx/jump_02.ogg")], "db": -9.0, "gap_ms": 45, "voices": 2},
	"boost": {"clips": [preload("res://assets/audio/sfx/boost_01.ogg")], "db": -10.0, "gap_ms": 45, "voices": 2},
	"land": {"clips": [preload("res://assets/audio/sfx/land_01.ogg"), preload("res://assets/audio/sfx/land_02.ogg")], "db": -12.0, "gap_ms": 65, "voices": 2},
	"boss_warn": {"clips": [preload("res://assets/audio/sfx/guardian_warn_01.ogg"), preload("res://assets/audio/sfx/guardian_warn_02.ogg")], "db": -9.0, "gap_ms": 160, "voices": 1, "priority": true},
	"boss_push": {"clips": [preload("res://assets/audio/sfx/guardian_rush_01.ogg"), preload("res://assets/audio/sfx/guardian_rush_02.ogg")], "db": -9.0, "gap_ms": 160, "voices": 1, "priority": true},
	"boss_hit": {"clips": [preload("res://assets/audio/sfx/guardian_hit_01.ogg"), preload("res://assets/audio/sfx/guardian_hit_02.ogg")], "db": -9.0, "gap_ms": 120, "voices": 1, "priority": true},
	"boss_step": {"clips": [preload("res://assets/audio/sfx/guardian_step_01.ogg"), preload("res://assets/audio/sfx/guardian_step_02.ogg")], "db": -18.0, "gap_ms": 95, "voices": 2},
	"boss_rest": {"clips": [preload("res://assets/audio/sfx/guardian_rest.ogg")], "db": -17.0, "gap_ms": 180, "voices": 1},
	"boss_free": {"clips": [preload("res://assets/audio/sfx/guardian_free.ogg")], "db": -11.0, "gap_ms": 500, "voices": 1, "priority": true}
}

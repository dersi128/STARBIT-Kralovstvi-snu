extends Camera2D
## The asset showroom uses a fixed viewport, while Bit expects this hook on respawn.
func reset_follow() -> void:
	reset_smoothing()

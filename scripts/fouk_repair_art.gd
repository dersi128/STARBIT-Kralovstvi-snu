extends RefCounted
## Shared, cached atlas frames. The original artwork stays in one texture.
const SHEET = preload("res://assets/characters/fouk_repair_sheet.png")
const DURATION := 2.0
const FRAME_COUNT := 8
const REGIONS := [
	Rect2(0,80,384,430), Rect2(384,80,384,430),
	Rect2(768,80,384,430), Rect2(1152,80,384,430),
	Rect2(0,520,400,430), Rect2(400,520,368,430),
	Rect2(768,520,384,430), Rect2(1152,520,384,430)
]
const BODY_X := [200.0,201.0,202.0,198.0,200.0,190.0,202.0,208.0]
static var frames: Array[AtlasTexture] = []

static func prepare() -> void:
	if not frames.is_empty():return
	for i in FRAME_COUNT:
		var texture := AtlasTexture.new()
		texture.atlas = SHEET
		texture.region = REGIONS[i]
		# The lower row sits higher in its source cells; these margins align
		# all body centres and keep the bottom-left fin entirely inside its crop.
		texture.margin = Rect2(Vector2(220.0-BODY_X[i],5),Vector2(440,440)-REGIONS[i].size)
		texture.filter_clip = true
		frames.append(texture)

static func frame(index:int) -> AtlasTexture:
	prepare()
	return frames[clampi(index, 0, FRAME_COUNT - 1)]

static func draw_pose(canvas:CanvasItem, progress:float, target:Rect2) -> void:
	var cursor := clampf(progress, 0.0, 1.0) * FRAME_COUNT
	var index := mini(floori(cursor), FRAME_COUNT - 1)
	# A short dissolve joins the hand-painted poses without a hard visual jump.
	var blend := smoothstep(0.75, 1.0, cursor - floorf(cursor)) if index < FRAME_COUNT - 1 else 0.0
	canvas.draw_texture_rect(frame(index), target, false, Color(1, 1, 1, 1.0 - blend))
	if blend > 0.0:
		canvas.draw_texture_rect(frame(index + 1), target, false, Color(1, 1, 1, blend))

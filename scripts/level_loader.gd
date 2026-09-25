extends CanvasLayer
## Holds one prepared level plus the small shared resources loaded in _ready/_draw.
## Scene instantiation and SceneTree changes always stay on the main thread.

const FONT = preload("res://assets/menu/pause/Nunito.ttf")
const STAR = preload("res://assets/menu/pause/star.svg")
const SHARED_PATHS = [
	"res://scenes/Bit.tscn",
	"res://assets/animations/bit_v2/bit_frames.tres",
	"res://assets/bit.png",
	"res://assets/pieces/fouk.png",
	"res://assets/pieces/flag.png",
	"res://assets/pieces/arch.png",
	"res://assets/pieces/bush.png",
	"res://assets/pieces/star.png",
	"res://assets/audio/adventure.ogg",
]

var _resources: Dictionary = {}
var _pending: Dictionary = {}
var _failed: Dictionary = {}
var _scene_path := ""
var _card: Control
var _bar: ProgressBar
var _star: TextureRect
var _caption: Label
var _age := 0.0
var _revealing := false
var _loading := false

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_card()
	set_process(false)

func prefetch(path: String) -> void:
	# A deferred menu warm-up must never replace a level the player just chose.
	if _loading and path != _scene_path:
		return
	_scene_path = path
	# Keep at most one PackedScene; the running level owns its own live resources.
	for old_path in _resources.keys():
		if old_path != path and old_path not in SHARED_PATHS:
			_resources.erase(old_path)
	_request(path)
	for shared in SHARED_PATHS:
		_request(shared)
	set_process(true)

func _request(path: String) -> void:
	if _resources.has(path) or _pending.has(path):
		return
	_failed.erase(path)
	if not ResourceLoader.exists(path):
		_failed[path] = true
		return
	var error := ResourceLoader.load_threaded_request(path)
	if error == OK:
		_pending[path] = true
	else:
		_failed[path] = true

func _process(delta: float) -> void:
	for path in _pending.keys():
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			continue
		_pending.erase(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			# Never call this while a request is still running: it would block.
			var resource := ResourceLoader.load_threaded_get(path)
			if resource != null and (path == _scene_path or path in SHARED_PATHS):
				_resources[path] = resource
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			ResourceLoader.load_threaded_get(path) # Release the failed request.
			_failed[path] = true
		else:
			_failed[path] = true
	if _card.visible:
		_age += delta
		_star.pivot_offset = _star.size * 0.5
		_star.rotation = sin(_age * 2.8) * 0.08
		_star.scale = Vector2.ONE * (1.0 + sin(_age * 3.6) * 0.045)
		if not _revealing:
			_bar.value = maxf(_bar.value, _resource_progress() * 92.0)
	elif _pending.is_empty():
		set_process(false)

func _path_progress(path: String) -> float:
	if _resources.has(path) or _failed.has(path):
		return 1.0
	if not _pending.has(path):
		return 0.0
	var progress: Array = []
	ResourceLoader.load_threaded_get_status(path, progress)
	return clampf(float(progress[0]), 0.0, 1.0) if not progress.is_empty() else 0.0

func _resource_progress() -> float:
	var shared := 0.0
	for path in SHARED_PATHS:
		shared += _path_progress(path)
	return _path_progress(_scene_path) * 0.8 + shared / SHARED_PATHS.size() * 0.2

func prepare_level(path: String) -> PackedScene:
	_loading = true
	_scene_path = path
	_revealing = false
	_age = 0.0
	_bar.value = 0.0
	_caption.text = "Chystáme cestu pro Bita…"
	_card.modulate = Color.WHITE
	_card.show()
	prefetch(path)
	# Give the loading card a rendered frame, even when the scene is already cached.
	await get_tree().process_frame
	await get_tree().process_frame
	while _pending.has(path) or _shared_pending():
		await get_tree().process_frame
	if _failed.has(path):
		return null
	return _resources.get(path) as PackedScene

func _shared_pending() -> bool:
	for path in SHARED_PATHS:
		if _pending.has(path):
			return true
	return false

func finish_progress() -> void:
	_revealing = true
	_bar.value = 100.0
	_caption.text = "Dobrodružství začíná!"

func reveal_level() -> void:
	var fade := create_tween()
	fade.tween_property(_card, "modulate:a", 0.0, 0.18)
	await fade.finished
	hide_loading()

func hide_loading() -> void:
	_loading = false
	_card.hide()
	set_process(not _pending.is_empty())

func _build_card() -> void:
	_card = Control.new()
	_card.name = "LoadingScreen"
	_card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_card.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_card)
	var shade := ColorRect.new()
	shade.color = Color(0.07, 0.17, 0.30, 0.84)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(580, 250)
	var skin := _rounded(Color("eefaff"), 28)
	skin.set_border_width_all(3)
	skin.border_color = Color("9de4ff")
	skin.shadow_size = 12
	skin.shadow_color = Color(0.02, 0.08, 0.20, 0.28)
	panel.add_theme_stylebox_override("panel", skin)
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 26)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	_star = TextureRect.new()
	_star.texture = STAR
	_star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_star.custom_minimum_size = Vector2(64, 64)
	_star.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(_star)
	column.add_child(_label("Načítání dobrodružství", 30))
	_caption = _label("Chystáme cestu pro Bita…", 20)
	column.add_child(_caption)
	_bar = ProgressBar.new()
	_bar.name = "LoadingProgress"
	_bar.custom_minimum_size = Vector2(0, 16)
	_bar.show_percentage = false
	_bar.add_theme_stylebox_override("background", _rounded(Color("d3e6f5"), 8))
	_bar.add_theme_stylebox_override("fill", _rounded(Color("59c9ef"), 8))
	column.add_child(_bar)
	_card.hide()

func _label(text: String, font_size: int) -> Label:
	var result := Label.new()
	result.text = text
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.add_theme_font_override("font", FONT)
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", Color("143e70"))
	return result

func _rounded(color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	return style

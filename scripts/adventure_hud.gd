extends Control
## A small health row, current objective and one carried quest item.
const FONT = preload("res://assets/ui/fonts/Nunito.ttf")
const GEAR = preload("res://assets/environment/forest/awakening/gear.png")
var level: Node2D
var objective: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	objective = Label.new()
	objective.position = Vector2(354, 22)
	objective.size = Vector2(794, 48)
	objective.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	objective.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective.add_theme_font_override("font", FONT)
	objective.add_theme_font_size_override("font_size", 21)
	objective.add_theme_color_override("font_color", Color("fff8de"))
	objective.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(objective)

func _process(_delta: float) -> void:
	if not is_instance_valid(level):return
	if level.has_method("objective_text"):objective.text = level.objective_text()
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(level) or not is_instance_valid(level.player):return
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.08, 0.23, 0.21, 0.90)
	panel.set_corner_radius_all(17)
	draw_style_box(panel, Rect2(342, 16, 820, 60))
	draw_style_box(panel, Rect2(22, 94, 177, 51))
	for i in 3:
		var points := PackedVector2Array()
		for j in 48:
			var t := TAU * j / 48.0
			points.append(Vector2(50 + i * 43, 117) + Vector2(16 * pow(sin(t), 3), -(13 * cos(t) - 5 * cos(2*t) - 2 * cos(3*t) - cos(4*t))) * 0.9)
		draw_colored_polygon(points, Color("ff8b92") if i < level.player.health else Color("52645f"))
	if level.inventory.get("bridge_gear", 0) > 0:
		draw_style_box(panel, Rect2(210, 94, 65, 51))
		draw_texture_rect(GEAR, Rect2(222, 100, 39, 39), false)

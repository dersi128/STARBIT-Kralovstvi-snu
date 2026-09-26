extends Control
const DREAM_SCREEN = preload("res://scripts/dream_screens.gd")
const DESIGN_SIZE = Vector2(1280, 720)
var backdrop: Control
var canvas: Control
## Same illustrated backdrop, fonts and glossy buttons as level selection.
const WARDROBE = preload("res://scripts/starbit_wardrobe.gd")
var character := "bit"
var preview_id := "original"
var content: Control
var on_back: Callable
var on_changed: Callable
var save_error := false

func setup(back: Callable, changed: Callable) -> void:
	name = "RewardsMenu"
	on_back = back
	on_changed = changed
	preview_id = WARDROBE.selected(character)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop = DREAM_SCREEN.new()
	add_child(backdrop)
	backdrop._base()
	canvas = backdrop.canvas
	_render()

func _render(focus_name := "") -> void:
	if is_instance_valid(content):
		canvas.remove_child(content)
		content.queue_free()
	content = Control.new()
	content.name = "WardrobeContent"
	content.size = DESIGN_SIZE
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(content)
	backdrop._panel(content, Rect2(64, 230, 1152, 474), Color("eaf7ff"))
	backdrop._text(content, "Odměny", Rect2(92, 240, 320, 48), 40, true)
	backdrop._text(content, "Nové barvy za hvězdy z levelů. Hvězdy ti zůstávají.", Rect2(96, 294, 1088, 32), 21)
	var bit_tab := _reward_button("Bit", "yellow", Rect2(706, 243, 222, 54), func(): _switch_character("bit"), "BitTab")
	var fouk_tab := _reward_button("Fouk", "blue", Rect2(950, 243, 222, 54), func(): _switch_character("fouk"), "FoukTab")
	bit_tab.disabled = character == "bit"
	fouk_tab.disabled = character == "fouk"
	var entry := WARDROBE.skin(character, preview_id)
	var active := WARDROBE.selected(character)
	backdrop._panel(content, Rect2(94, 340, 296, 270), Color("ffffff"), 28)
	var portrait: TextureRect = backdrop._picture(content, _portrait_texture(), Rect2(116, 356, 252, 202))
	portrait.name = "CharacterPreview"
	portrait.material = WARDROBE.material_for(character, preview_id)
	backdrop._text(content, entry.title, Rect2(104, 562, 276, 33), 23, true)
	for index in WARDROBE.SKINS[character].size():
		var reward: Dictionary = WARDROBE.SKINS[character][index]
		var id: String = reward.id
		var card := DREAM_SCREEN.LevelCard.new()
		card.name = "Skin_" + id
		card.position = Vector2(412 + (index % 2) * 392, 340 + floori(index / 2.0) * 142)
		card.size = Vector2(370, 128)
		card.tooltip_text = reward.title
		card.activate = func(_number: int): _preview_skin(id)
		card.prepare(id == preview_id)
		content.add_child(card)
		var thumbnail: TextureRect = backdrop._picture(card, _portrait_texture(), Rect2(12, 10, 92, 106))
		thumbnail.material = WARDROBE.material_for(character, id)
		backdrop._text(card, reward.title, Rect2(112, 13, 244, 35), 22, true)
		var unlocked := WARDROBE.is_unlocked(character, id)
		var status := "Používáš" if id == active else ("Odemčeno" if unlocked else "Chybí %d" % (int(reward.stars) - Progress.total_stars()))
		var status_label: Label = backdrop._text(card, status, Rect2(120, 51, 206, 30), 20)
		status_label.add_theme_color_override("font_color", Color("238166") if unlocked else Color("675779"))
		if not unlocked:backdrop._picture(card, DREAM_SCREEN.GOLD_STAR, Rect2(323, 54, 23, 23))
		backdrop._text(card, "Základní vzhled" if int(reward.stars) == 0 else "Odměna za %d hvězd" % int(reward.stars), Rect2(112, 86, 244, 26), 17)
		if not unlocked:backdrop._picture(card, DREAM_SCREEN.LOCK, Rect2(78, 88, 23, 27))
	var unlocked := WARDROBE.is_unlocked(character, preview_id)
	var caption := "Používáš" if preview_id == active else ("Použít vzhled" if unlocked else "Ještě zamčeno")
	_reward_button("Zpět", "purple", Rect2(96, 628, 284, 60), on_back, "BackButton")
	backdrop._text(content, "Fouk si barvy oblékne, až ho opravíš." if character == "fouk" else "Barvy můžeš kdykoliv změnit.", Rect2(406, 633, 405, 50), 18)
	var use_button := _reward_button(caption, "green", Rect2(833, 628, 344, 60), _equip, "EquipButton")
	use_button.disabled = not unlocked or preview_id == active
	if use_button.disabled:use_button.modulate = Color(0.77, 0.85, 0.88)
	if save_error:
		backdrop._text(content, "Vzhled se nepodařilo uložit. Zkus to znovu.", Rect2(402, 605, 770, 25), 17).add_theme_color_override("font_color", Color("9b3455"))
	if not focus_name.is_empty():
		var focus := content.find_child(focus_name, true, false) as Control
		if focus:_restore_focus.call_deferred(focus)

func _restore_focus(control: Control) -> void:
	if is_instance_valid(control) and control.is_inside_tree():control.grab_focus()

func _portrait_texture() -> Texture2D:
	return DreamArt.texture("front" if character == "bit" else "fouk")

func _reward_button(caption: String, palette: String, bounds: Rect2, action: Callable, node_name: String) -> Button:
	var button := DREAM_SCREEN.BUTTON_THEME.button(caption, action, palette)
	button.name = node_name
	button.custom_minimum_size = bounds.size
	button.position = bounds.position
	button.size = bounds.size
	button.add_theme_font_size_override("font_size", 25)
	content.add_child(button)
	return button

func _switch_character(next: String) -> void:
	character = next
	preview_id = WARDROBE.selected(character)
	save_error = false
	_render("FoukTab" if character == "bit" else "BitTab")

func _preview_skin(id: String) -> void:
	preview_id = id
	save_error = false
	_render("Skin_" + id)

func _equip() -> void:
	var result := WARDROBE.equip(character, preview_id)
	save_error = result != OK
	if not save_error:on_changed.call()
	_render("Skin_" + preview_id)

@tool
extends Node2D
## Bells stay lit after a fall. All three awaken the exit carrier, in any order.
@export var bells:Array[NodePath]=[]
@export var carrier:NodePath
@export var wind_travel:=Vector2(1050,-80)
@export var progress_area:=Rect2(9000,-800,4800,2000)
var active:=false
var count:=0
var completed_age:=0.0
var progress_label:Label
var progress_card:PanelContainer
var count_label:Label
var bell_icons:Array[TextureRect]=[]
const FONT=preload("res://assets/menu/pause/Nunito.ttf")
const HUD=preload("res://scripts/collectible_hud.gd")
const CHIME=preload("res://scripts/sky_chime.gd")
func _ready() -> void:
	z_index=2
	if Engine.is_editor_hint():return
	add_to_group("sky_bell_objectives")
	var layer:=CanvasLayer.new();layer.layer=4;add_child(layer)
	progress_card=HUD.GlossyCard.new();progress_card.name="BellProgress"
	progress_card.custom_minimum_size=Vector2(320,68)
	progress_card.set_palette(Color("c2efd4"),Color("f3ffeb"),16)
	progress_card.visible=false;layer.add_child(progress_card)
	var row:=HBoxContainer.new();row.mouse_filter=Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation",14);progress_card.add_child(row)
	var words:=VBoxContainer.new();words.mouse_filter=Control.MOUSE_FILTER_IGNORE
	words.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	words.add_theme_constant_override("separation",0);row.add_child(words)
	progress_label=_label(20);words.add_child(progress_label)
	count_label=_label(15);words.add_child(count_label)
	var texture:=AtlasTexture.new();texture.atlas=CHIME.ART;texture.region=CHIME.BELL
	var icons:=HBoxContainer.new();icons.mouse_filter=Control.MOUSE_FILTER_IGNORE
	icons.add_theme_constant_override("separation",6);row.add_child(icons)
	for i in bells.size():
		var icon:=TextureRect.new();icon.texture=texture
		icon.custom_minimum_size=Vector2(33,44)
		icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
		icons.add_child(icon);bell_icons.append(icon)
	_update_progress()
func _label(font_size:int) -> Label:
	var label:=Label.new();label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var typeface:=FontVariation.new();typeface.base_font=FONT
	typeface.variation_opentype={0x77676874:800.0}
	label.add_theme_font_override("font",typeface)
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",Color("174e50"))
	return label
func _physics_process(delta:float) -> void:
	if Engine.is_editor_hint():return
	count=0
	for path in bells:
		var bell:=get_node_or_null(path)
		if bell!=null and bell.active:count+=1
	if not active and not bells.is_empty() and count==bells.size():
		active=true
		var ferry:=get_node_or_null(carrier)
		if ferry!=null:ferry.configure_wind(wind_travel)
		Progress.sfx("repair")
	if active:completed_age+=delta
	_update_progress()
func _update_progress() -> void:
	if not is_instance_valid(progress_card):return
	progress_card.visible=wants_hud_priority()
	progress_card.position=Vector2((get_viewport().get_visible_rect().size.x-progress_card.size.x)/2,18)
	progress_label.text="Píseň oblak"
	count_label.text="Cesta k bráně je otevřená" if active else "Zvonky %d / %d"%[count,bells.size()]
	for i in bell_icons.size():
		var bell:=get_node_or_null(bells[i])
		bell_icons[i].modulate=Color.WHITE if bell!=null and bell.active else Color(0.42,0.57,0.59,0.45)
func wants_hud_priority() -> bool:
	# The quest owns the shared top slot while Bit is solving it. Do not infer
	# priority from another card's visibility: that creates a one-frame loop.
	var player:=get_tree().get_first_node_in_group("player") as Node2D
	return player!=null and progress_area.has_point(player.global_position) and (not active or completed_age<3.0)
func _draw() -> void:
	# The editor retains a marker, but the runtime has only the compact HUD card.
	if not Engine.is_editor_hint():return
	var text:="Píseň oblak"
	var extent:=FONT.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,20)
	draw_string_outline(FONT,Vector2(-extent.x/2,-130),text,HORIZONTAL_ALIGNMENT_LEFT,-1,20,5,Color("203e57"))
	draw_string(FONT,Vector2(-extent.x/2,-130),text,HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("fff4cb"))

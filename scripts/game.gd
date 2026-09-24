extends Node
const MOLE_DIALOGUE=preload("res://scripts/mole_dialogue.gd")
const DREAM_SCREENS=preload("res://scripts/dream_screens.gd")
const COLLECTIBLE_HUD=preload("res://scripts/collectible_hud.gd")
const PAUSE_THEME=preload("res://scripts/pause_menu_theme.gd")
const ILLUSTRATED_MENU=preload("res://scripts/illustrated_menu.gd")
var preview_number := 0
var level: Node2D
var current := 1
var selected_region:=0
var selected_level:=1
var screws := 0
var gold := 0
var crystals:=0
var total_crystals:=0
var run_finished:=false
var preview_scene_path:=""
var current_scene_path:=""
var mode := "menu"
var ui:CanvasLayer
var screen:Control
var hud:COLLECTIBLE_HUD
var tip:Label
var tip_time:=0.0
var music_time:=0.0
var music_step:=0
var touch:Control
var bubble:PanelContainer
var bubble_text:Label
var bubble_name:Label
var bubble_tail:Polygon2D
var speaker:Node2D
var speech_age:=0.0
var speech_progress:=0.0
var speech_last_sound:=-1
var speech_content:=""
var speech_voice:="voice_mole"
var hero:TextureRect
var mole_dialogue:Control
var dialogue_session:=0
const TITLES=["Lesní probuzení", "Mezi kořeny", "Světélka vesničky", "Nad střechami", "Brúčounova svatyně", "První ostrovy", "Vodopády v oblacích", "Hrad na dosah", "Královské zahrady", "Nebeské nádvoří"]
const LEVEL_COUNT=10
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 add_to_group("game")
 for action in ["left","right","jump"]:
  if not InputMap.has_action(action):InputMap.add_action(action)
 var keys={"left":[KEY_LEFT,KEY_A],"right":[KEY_RIGHT,KEY_D],"jump":[KEY_SPACE,KEY_UP]}
 for a in keys:
  for key in keys[a]:
   var e:=InputEventKey.new();e.physical_keycode=key;InputMap.action_add_event(a,e)
 ui=CanvasLayer.new();add_child(ui)
 if preview_number>0:start_level(preview_number,preview_scene_path)
 else:menu()
func clear_ui() -> void:
 dialogue_session+=1
 mole_dialogue=null
 speaker=null
 speech_content=""
 bubble=null
 hero=null
 for c in ui.get_children():
  ui.remove_child(c)
  c.queue_free()
 screen=Control.new();screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);ui.add_child(screen)
func box_style(color:Color) -> StyleBoxFlat:
 var s:=StyleBoxFlat.new();s.bg_color=color
 s.set_corner_radius_all(30);s.set_border_width_all(3);s.border_color=color.lightened(0.35)
 s.shadow_color=Color(0.04,0.1,0.25,0.3);s.shadow_size=5;s.shadow_offset=Vector2(0,5)
 return s
func button(text:String,action:Callable,color:Color=Color("79cef0")) -> Button:
 var b:=Button.new();b.text=text;b.custom_minimum_size=Vector2(390,60)
 b.add_theme_font_size_override("font_size",25)
 b.add_theme_color_override("font_color",Color("143458"))
 b.add_theme_stylebox_override("normal",box_style(color))
 b.add_theme_stylebox_override("hover",box_style(color.lightened(0.12)))
 b.add_theme_stylebox_override("pressed",box_style(color.darkened(0.08)))
 b.add_theme_stylebox_override("focus",box_style(color.lightened(0.22)))
 b.add_theme_stylebox_override("disabled",box_style(color.lerp(Color("d9e6ec"),0.55)))
 b.add_theme_color_override("font_disabled_color",Color("536e85"))
 b.pressed.connect(func():Progress.sfx("ui");action.call())
 b.mouse_entered.connect(func():b.create_tween().tween_property(b,"modulate",Color(1.07,1.07,1.07),0.12))
 b.mouse_exited.connect(func():b.create_tween().tween_property(b,"modulate",Color.WHITE,0.12))
 return b
func centered_panel(title:String) -> VBoxContainer:
 clear_ui()
 var wash:=ColorRect.new();wash.color=Color(0.1,0.22,0.4,0.28);wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);screen.add_child(wash)
 var center:=CenterContainer.new();center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);screen.add_child(center)
 var panel:=PanelContainer.new();panel.add_theme_stylebox_override("panel",box_style(Color(0.94,0.98,1,0.93)));center.add_child(panel)
 var margin:=MarginContainer.new()
 for side in ["left","right","top","bottom"]:margin.add_theme_constant_override("margin_"+side,20)
 panel.add_child(margin)
 var v:=VBoxContainer.new();v.add_theme_constant_override("separation",10);margin.add_child(v)
 var l:=Label.new();l.text=title;l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;l.add_theme_font_size_override("font_size",34);l.add_theme_color_override("font_color",Color("205080"));v.add_child(l)
 return v
func background() -> void:
 var bg:=TextureRect.new();bg.name="MenuBackground";bg.texture=load("res://assets/menu/kingdom_adventure.png");bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);bg.mouse_filter=Control.MOUSE_FILTER_IGNORE;screen.add_child(bg);screen.move_child(bg,0)
func title_label(text:String,where:Vector2,font_size:int,color:Color) -> Label:
 var l:=Label.new();l.text=text;l.position=where;l.add_theme_font_size_override("font_size",font_size);l.add_theme_color_override("font_color",color);l.add_theme_color_override("font_outline_color",Color("143562"));l.add_theme_constant_override("outline_size",9);screen.add_child(l);return l
func menu() -> void:
 mode="menu";Progress.silence();release_input()
 Progress.play_music("menu_adventure")
 if level:level.process_mode=Node.PROCESS_MODE_DISABLED
 clear_ui()
 var presentation:=ILLUSTRATED_MENU.new()
 screen.add_child(presentation)
 presentation.setup({
  "new":func():start_level(1),
  "continue":_continue_from_menu,
  "settings":settings,
  "credits":credits,
  "quit":func():get_tree().quit()
 },is_instance_valid(level) or Progress.unlocked>1)
func _continue_from_menu() -> void:
 if run_finished:selection()
 elif is_instance_valid(level):resume()
 else:
  selected_level=Progress.unlocked;selected_region=floori((selected_level-1)/5.0);selection()
func settings() -> void:
 var v:=centered_panel("Nastavení")
 if mode=="menu":
  background()
  Progress.play_music("menu_adventure")
 v.add_child(button("Zvuk: "+("vypnutý" if Progress.muted else "zapnutý"),func():Progress.muted=not Progress.muted;Progress.silence();Progress.save();settings(),Color("d2b0f7")))
 var l:=Label.new();l.text="Pohyb: ← → nebo A/D\nSkok: mezerník nebo ↑\nPauza: Escape\nFouk: druhý stisk skoku ve vzduchu";l.add_theme_color_override("font_color",Color("143458"));l.add_theme_font_size_override("font_size",20);v.add_child(l)
 v.add_child(button("Zpět",menu,Color("78d4f8")))
func credits() -> void:
 var v:=centered_panel("Velora")
 if mode=="menu":background()
 var l:=Label.new();l.text="STARBIT · Království snů\nBit, Jiskra, Fouk a jejich dobrodružství.\nVytvořeno podle dodaných výtvarných předloh.";l.add_theme_color_override("font_color",Color("143458"));l.add_theme_font_size_override("font_size",20);v.add_child(l)
 v.add_child(button("Zpět",menu,Color("f6abc9")))
func selection() -> void:
 mode="selection";release_input()
 if is_instance_valid(level):level.process_mode=Node.PROCESS_MODE_DISABLED
 clear_ui()
 selected_region=clampi(selected_region,0,ceili(LEVEL_COUNT/5.0)-1)
 var first:=selected_region*5+1
 if selected_level<first or selected_level>=first+5:selected_level=first
 var view:=DREAM_SCREENS.new();screen.add_child(view)
 view.show_selection(TITLES,selected_region,selected_level,{
  "select":func(n:int):selected_level=n;selection(),
  "page":func(direction:int):selected_region+=direction;selected_level=selected_region*5+1;selection(),
  "play":func():start_level(selected_level),
  "back":menu
 })
func start_level(n:int,custom_scene:String="") -> void:
 if level:remove_child(level);level.queue_free()
 release_input()
 current=n;screws=0;gold=0;crystals=0;total_crystals=0;run_finished=false;mode="play"
 current_scene_path=custom_scene if not custom_scene.is_empty() else "res://levels/Level_%02d.tscn"%n
 level=load(current_scene_path).instantiate()
 add_child(level)
 # Count only this instance: the previous level can still be queued for deletion.
 for object in get_tree().get_nodes_in_group("objects"):
  if level.is_ancestor_of(object) and object.kind=="crystal":total_crystals+=1
 game_ui()
func release_input() -> void:
 for a in ["left","right","jump"]:Input.action_release(a)
func game_ui() -> void:
 clear_ui()
 hud=COLLECTIBLE_HUD.new();hud.position=Vector2(22,16);screen.add_child(hud)
 hud.update_values(crystals,level.star_collected,total_crystals,false)
 var pause_button:=button("Ⅱ",pause_game);pause_button.custom_minimum_size=Vector2(64,50);pause_button.position=Vector2(1188,16);screen.add_child(pause_button)
 build_bubble()
 touch=Control.new();screen.add_child(touch)
 for spec in [["←","left",32],["→","right",140],["↑","jump",1140]]:
  var b:=button(spec[0],func():pass,Color(0.8,0.95,1,0.65));b.position=Vector2(spec[2],620);b.custom_minimum_size=Vector2(84,80);b.size=Vector2(84,80)
  var a:String=spec[1]
  b.button_down.connect(func():Input.action_press(a))
  b.button_up.connect(func():Input.action_release(a))
  touch.add_child(b)
  b.set_deferred("size",Vector2(84,80))
  if OS.has_feature("android") or OS.has_feature("ios"):
   b.mouse_filter=Control.MOUSE_FILTER_IGNORE
  var finger:=TouchScreenButton.new()
  var area:=RectangleShape2D.new();area.size=Vector2(96,92)
  finger.shape=area;finger.position=b.position+Vector2(42,40);finger.action=a
  finger.pressed.connect(func():b.modulate=Color(0.8,0.9,1))
  finger.released.connect(func():b.modulate=Color.WHITE)
  touch.add_child(finger)
func pause_game() -> void:
 if mode!="play":return
 mode="pause";level.process_mode=Node.PROCESS_MODE_DISABLED;release_input();Progress.silence()
 var v:=centered_panel("Chvilka oddechu")
 v.add_child(PAUSE_THEME.button("Pokračovat",resume,"blue"))
 v.add_child(PAUSE_THEME.button("Restartovat level",func():start_level(current,current_scene_path),"yellow"))
 v.add_child(PAUSE_THEME.button("Výběr levelu",selection,"green"))
 v.add_child(PAUSE_THEME.button("Hlavní menu",menu,"purple"))
func resume() -> void:
 if run_finished:selection();return
 mode="play";level.process_mode=Node.PROCESS_MODE_INHERIT;game_ui()
func hint(_text:String) -> void:
 pass # All guidance is delivered by Krtecek in speech bubbles.
func collect_crystal() -> void:
 crystals+=1
func enter_portal() -> void:
 if mode!="play":return
 mode="transition";run_finished=true
 level.process_mode=Node.PROCESS_MODE_DISABLED
 level.player.frozen=true
 release_input()
 call_deferred("_show_level_result")
func _show_level_result() -> void:
 if mode!="transition":return
 var result:Dictionary=Progress.record_level_result(current,crystals,total_crystals)
 mode="result";Progress.silence();Progress.play_music("victory")
 clear_ui()
 var view:=DREAM_SCREENS.new();screen.add_child(view)
 view.show_result(current,level.title,crystals,total_crystals,result,{
  "next":func():start_level(current+1),
  "replay":func():start_level(current,current_scene_path),
  "menu":menu,
  "selection":func():selected_level=current;selected_region=floori((current-1)/5.0);selection()
 })
func win() -> void:
 enter_portal()
func _process(delta:float) -> void:
 if Input.is_action_just_pressed("ui_cancel"):
  if mode=="play":pause_game()
  elif mode=="pause":resume()
  elif mode=="selection":menu()
 if mode!="play":return
 update_speech(delta)
 tip_time-=delta
 if tip_time<=0 and is_instance_valid(tip):tip.text=""
 if is_instance_valid(hud):
  hud.update_values(crystals,level.star_collected,total_crystals)
 var boss=get_tree().get_first_node_in_group("boss")
 var track:="adventure"
 if boss and boss.defeated:track="victory"
 elif boss and boss.state!="sleep":track="boss"
 Progress.play_music(track)

func build_bubble() -> void:
 bubble=PanelContainer.new();bubble.name="SpeechBubble";bubble.custom_minimum_size=Vector2(420,150);bubble.mouse_filter=Control.MOUSE_FILTER_IGNORE;bubble.add_theme_stylebox_override("panel",box_style(Color("fff8e7")));screen.add_child(bubble)
 var margin:=MarginContainer.new();margin.add_theme_constant_override("margin_left",18);margin.add_theme_constant_override("margin_right",18);margin.add_theme_constant_override("margin_top",12);margin.add_theme_constant_override("margin_bottom",16);bubble.add_child(margin)
 var v:=VBoxContainer.new();v.add_theme_constant_override("separation",5);margin.add_child(v)
 bubble_name=Label.new();bubble_name.add_theme_font_size_override("font_size",19);bubble_name.add_theme_color_override("font_color",Color("337e68"));v.add_child(bubble_name)
 bubble_text=Label.new();bubble_text.custom_minimum_size=Vector2(384,85);bubble_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;bubble_text.add_theme_font_size_override("font_size",20);bubble_text.add_theme_color_override("font_color",Color("293f52"));v.add_child(bubble_text)
 bubble_tail=Polygon2D.new();bubble_tail.polygon=PackedVector2Array([Vector2(190,147),Vector2(214,170),Vector2(238,147)]);bubble_tail.color=Color("fff8e7");bubble.add_child(bubble_tail)
 bubble.visible=false
func speak(source:Node2D,text:String,voice:String="voice_mole") -> void:
 if mode!="play" or not is_instance_valid(bubble) or text.is_empty():return
 if current==1 and source.get("kind")=="mole":
  if source.get_meta("story_read",false):return
  _begin_mole_dialogue(source)
  return
 if is_instance_valid(speaker) and speaker!=source:
  var player=get_tree().get_first_node_in_group("player")
  if player and speaker.global_position.distance_to(player.global_position)<source.global_position.distance_to(player.global_position):return
 speech_age=0
 if speaker!=source or speech_content!=text:
  speaker=source;speech_content=text;speech_progress=0;speech_last_sound=-1;speech_voice=voice
  bubble_text.text=text.trim_prefix("Krteček: ").trim_prefix("Jiskra: ")
  bubble_text.visible_characters=0
  bubble_name.text="Brúčoun" if voice=="voice_bear" else ("Krteček" if voice=="voice_mole" else "Jiskra")
 bubble.visible=true
func _begin_mole_dialogue(source:Node2D) -> void:
 if source.message.strip_edges().is_empty():return
 mode="dialogue";dialogue_session+=1
 var session:=dialogue_session
 var paused_level:=level
 var previous_process_mode:=level.process_mode
 var touch_was_visible:=touch.visible
 var previous_touch_mode:=touch.process_mode
 level.process_mode=Node.PROCESS_MODE_DISABLED
 touch.hide();touch.process_mode=Node.PROCESS_MODE_DISABLED
 release_input()
 level.player.buffer=0.0
 bubble.hide();speaker=null;speech_content=""
 mole_dialogue=MOLE_DIALOGUE.new()
 screen.add_child(mole_dialogue)
 mole_dialogue.setup(source.message)
 mole_dialogue.finished.connect(func():_finish_mole_dialogue(source,paused_level,session,previous_process_mode,touch_was_visible,previous_touch_mode))
func _finish_mole_dialogue(source:Node2D,paused_level:Node2D,session:int,previous_process_mode:int,touch_was_visible:bool,previous_touch_mode:int) -> void:
 if session!=dialogue_session or mode!="dialogue":return
 if is_instance_valid(source):source.set_meta("story_read",true)
 release_input()
 # Wait beyond the confirming input frame before physics is allowed to run.
 await get_tree().process_frame
 await get_tree().physics_frame
 if session!=dialogue_session or mode!="dialogue" or not is_instance_valid(paused_level) or level!=paused_level:return
 release_input()
 level.player.buffer=0.0
 if is_instance_valid(mole_dialogue):mole_dialogue.queue_free()
 mole_dialogue=null
 touch.visible=touch_was_visible;touch.process_mode=previous_touch_mode
 mode="play";level.process_mode=previous_process_mode

func update_speech(delta:float) -> void:
 if not is_instance_valid(bubble):return
 speech_age+=delta
 if not is_instance_valid(speaker) or speech_age>0.2:
  bubble.visible=false;speaker=null;return
 speech_progress+=delta*42
 bubble_text.visible_characters=int(speech_progress)
 var index:=int(speech_progress)/4
 if index>speech_last_sound and speech_progress<bubble_text.text.length():
  speech_last_sound=index
  if not bubble_text.text.substr(int(speech_progress),1).strip_edges().is_empty():Progress.sfx("voice_mole" if speech_voice=="voice_bear" else speech_voice)
 var anchor:Vector2=speaker.get_global_transform_with_canvas().origin
 var height:=150.0 if speech_voice=="voice_bear" else 94.0
 bubble.position=Vector2(clampf(anchor.x-210,16,screen.size.x-436),clampf(anchor.y-height-190,16,screen.size.y-190))
 var tail_x:=clampf(anchor.x-bubble.position.x,30,390)
 var by:=bubble.size.y
 bubble_tail.polygon=PackedVector2Array([Vector2(tail_x-17,by-2),Vector2(tail_x,by+18),Vector2(tail_x+17,by-2)])

func _notification(what:int) -> void:
 if what==NOTIFICATION_APPLICATION_PAUSED or what==NOTIFICATION_WM_GO_BACK_REQUEST:
  if mode=="play":pause_game()

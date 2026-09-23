@tool
extends Node2D
@export_enum("checkpoint","goal","mole","fouk","jiskra","arch","bush","star_key","crystal","crate","push_crate","spring_pad","stone_block","wood_bridge","island_wide","island_small","sign","fence","lantern","flowers","vines","waterfall","water_surface","rock_enemy","cloud_enemy","stinko","asset_piece","piece_GrassLeft","piece_GrassMiddle","piece_GrassMiddleB","piece_GrassRight","piece_StoneGrassLeft","piece_StoneGrassMiddle","piece_StoneGrassMiddleB","piece_StoneGrassRight","piece_IslandTiny","piece_IslandRound","piece_IslandVines","piece_IslandStar","piece_IslandStone","piece_IslandWide","piece_IslandPoint","piece_IslandLow","piece_IslandSmall","piece_StarBlock","piece_StarBlockWide","piece_SlopeDown","piece_SlopeUp","piece_CliffLeft","piece_CliffRight","piece_CliffVines","piece_CliffEnd","piece_BridgeLeft","piece_BridgeMiddle","piece_BridgeRight","piece_BridgeSmall","piece_IslandPebbles","piece_IslandTall","piece_SignArrow","piece_SignDouble","piece_Banner","piece_FlagRope","piece_BannerStar","piece_Fence","piece_RopeFence","piece_Bush","piece_BushFlowers","piece_LeavesWide","piece_LeavesSmall","piece_LeavesTall","piece_VinesShort","piece_VinesLong","piece_StoneColumn","piece_BrokenColumn","piece_Ruins","piece_StoneSlab","piece_FallenRocks","piece_LanternPost","piece_LanternHook","piece_MushroomRed","piece_MushroomSmall","piece_MushroomBlue","piece_Barrel","piece_CloudWide","piece_CloudLong","piece_CloudSmall","piece_CloudPair","piece_WaterfallWide","piece_WaterfallMedium","piece_WaterfallSlim","piece_WaterfallThin","piece_SplashWide","piece_SplashSmall","piece_Foam","piece_RiverSurface","piece_RiverLeft","piece_RiverMiddle","piece_RiverRight","piece_FallsLongThin","piece_FallsLongA","piece_FallsLongWide","piece_FallsLongB","piece_FallsLongLarge","piece_FallsBodyA","piece_FallsBodyB","piece_FallsBodyC","piece_FallsMist","piece_WaterIslandLeft","piece_WaterIslandWide","piece_WaterIslandRight","piece_WaterIslandSlim","piece_FallsIsland","piece_FallsTwinIsland","piece_FallsWideIsland","piece_FallsMossIsland","piece_FallsStoneIsland","piece_FallsRock","piece_FallsStarRock","piece_FallsSteps","piece_RockShards","piece_RockShardsTall","piece_ArchDecor","piece_BoulderMoss","piece_BoulderRound","piece_BoulderSmall","piece_RockAngular","piece_RockSmall","piece_Pebble","piece_RockPatch","piece_BushLow","piece_BushLowFlowers","piece_StarDecorLarge","piece_StarDecorMedium","piece_StarDecorSmall","piece_StarDecorTilt","piece_ShootingStar","piece_StarTrail","piece_CrateOrnate","piece_LanternHanging","piece_LanternPostSmall","piece_VineRight","piece_CloudPuff","piece_CloudLow","piece_IslandGarden","piece_WaterIslandTall","piece_WaterIslandTiny","piece_WaterIslandEdge","piece_TwinWaterIsland","piece_ThinWaterIsland","piece_RoundWaterIsland","piece_WaterfallNarrow","piece_SplashRight","piece_DropsWide","piece_DropsTall","piece_Drop","piece_DropsPair","piece_FoamMedium","piece_FoamWide","piece_FoamSmall","piece_RiverSurfaceMedium","piece_RiverSurfaceShort","piece_RiverSurfaceSmall","piece_RiverSurfaceTiny","piece_FallsNarrowIsland","piece_FallsIslandEdge","piece_FallsWallIsland","piece_FallsGardenIsland","piece_FallsSmallIsland","piece_FallsTinyIsland","piece_FallsLongNeedle","piece_FallsBodyD","piece_FallsBodyE","piece_FallsBodyF","piece_FallsDropsA","piece_FallsDropsB","piece_FallsDropsC") var kind := "crystal":
	set(v):
		kind=v;queue_redraw()
		if is_inside_tree():call_deferred("_refresh_kit")
@export var asset_scene:PackedScene:
	set(v):
		asset_scene=v
		if is_inside_tree():call_deferred("_refresh_kit")
@export var gate_scale := 2.0:
	set(v): gate_scale=v;queue_redraw()
@export var gate_flip := true:
	set(v): gate_flip=v;queue_redraw()
@export_multiline var message := ""
const KIT_SCENES = {
	"crate": "res://scenes/worldkit/Crate.tscn",
	"push_crate": "res://scenes/worldkit/PushCrate.tscn",
	"spring_pad": "res://scenes/worldkit/SpringPad.tscn",
	"stone_block": "res://scenes/worldkit/StoneBlock.tscn",
	"wood_bridge": "res://scenes/worldkit/WoodBridge.tscn",
	"island_wide": "res://scenes/worldkit/IslandWide.tscn",
	"island_small": "res://scenes/worldkit/IslandSmall.tscn",
	"sign": "res://scenes/worldkit/Sign.tscn",
	"fence": "res://scenes/worldkit/Fence.tscn",
	"lantern": "res://scenes/worldkit/Lantern.tscn",
	"flowers": "res://scenes/worldkit/BushFlowers.tscn",
	"vines": "res://scenes/worldkit/Vines.tscn",
	"waterfall": "res://scenes/worldkit/Waterfall.tscn",
	"water_surface": "res://scenes/worldkit/WaterSurface.tscn",
	"rock_enemy": "res://scenes/Enemy_rock_enemy.tscn",
	"cloud_enemy": "res://scenes/Enemy_cloud_enemy.tscn",
	"stinko": "res://scenes/Enemy_stinko.tscn",
	"piece_GrassLeft": "res://scenes/supplied/GrassLeft.tscn",
	"piece_GrassMiddle": "res://scenes/supplied/GrassMiddle.tscn",
	"piece_GrassMiddleB": "res://scenes/supplied/GrassMiddleB.tscn",
	"piece_GrassRight": "res://scenes/supplied/GrassRight.tscn",
	"piece_StoneGrassLeft": "res://scenes/supplied/StoneGrassLeft.tscn",
	"piece_StoneGrassMiddle": "res://scenes/supplied/StoneGrassMiddle.tscn",
	"piece_StoneGrassMiddleB": "res://scenes/supplied/StoneGrassMiddleB.tscn",
	"piece_StoneGrassRight": "res://scenes/supplied/StoneGrassRight.tscn",
	"piece_IslandTiny": "res://scenes/supplied/IslandTiny.tscn",
	"piece_IslandRound": "res://scenes/supplied/IslandRound.tscn",
	"piece_IslandVines": "res://scenes/supplied/IslandVines.tscn",
	"piece_IslandStar": "res://scenes/supplied/IslandStar.tscn",
	"piece_IslandStone": "res://scenes/supplied/IslandStone.tscn",
	"piece_IslandWide": "res://scenes/supplied/IslandWide.tscn",
	"piece_IslandPoint": "res://scenes/supplied/IslandPoint.tscn",
	"piece_IslandLow": "res://scenes/supplied/IslandLow.tscn",
	"piece_IslandSmall": "res://scenes/supplied/IslandSmall.tscn",
	"piece_StarBlock": "res://scenes/supplied/StarBlock.tscn",
	"piece_StarBlockWide": "res://scenes/supplied/StarBlockWide.tscn",
	"piece_SlopeDown": "res://scenes/supplied/SlopeDown.tscn",
	"piece_SlopeUp": "res://scenes/supplied/SlopeUp.tscn",
	"piece_CliffLeft": "res://scenes/supplied/CliffLeft.tscn",
	"piece_CliffRight": "res://scenes/supplied/CliffRight.tscn",
	"piece_CliffVines": "res://scenes/supplied/CliffVines.tscn",
	"piece_CliffEnd": "res://scenes/supplied/CliffEnd.tscn",
	"piece_BridgeLeft": "res://scenes/supplied/BridgeLeft.tscn",
	"piece_BridgeMiddle": "res://scenes/supplied/BridgeMiddle.tscn",
	"piece_BridgeRight": "res://scenes/supplied/BridgeRight.tscn",
	"piece_BridgeSmall": "res://scenes/supplied/BridgeSmall.tscn",
	"piece_IslandPebbles": "res://scenes/supplied/IslandPebbles.tscn",
	"piece_IslandTall": "res://scenes/supplied/IslandTall.tscn",
	"piece_SignArrow": "res://scenes/supplied/SignArrow.tscn",
	"piece_SignDouble": "res://scenes/supplied/SignDouble.tscn",
	"piece_Banner": "res://scenes/supplied/Banner.tscn",
	"piece_FlagRope": "res://scenes/supplied/FlagRope.tscn",
	"piece_BannerStar": "res://scenes/supplied/BannerStar.tscn",
	"piece_Fence": "res://scenes/supplied/Fence.tscn",
	"piece_RopeFence": "res://scenes/supplied/RopeFence.tscn",
	"piece_Bush": "res://scenes/supplied/Bush.tscn",
	"piece_BushFlowers": "res://scenes/supplied/BushFlowers.tscn",
	"piece_LeavesWide": "res://scenes/supplied/LeavesWide.tscn",
	"piece_LeavesSmall": "res://scenes/supplied/LeavesSmall.tscn",
	"piece_LeavesTall": "res://scenes/supplied/LeavesTall.tscn",
	"piece_VinesShort": "res://scenes/supplied/VinesShort.tscn",
	"piece_VinesLong": "res://scenes/supplied/VinesLong.tscn",
	"piece_StoneColumn": "res://scenes/supplied/StoneColumn.tscn",
	"piece_BrokenColumn": "res://scenes/supplied/BrokenColumn.tscn",
	"piece_Ruins": "res://scenes/supplied/Ruins.tscn",
	"piece_StoneSlab": "res://scenes/supplied/StoneSlab.tscn",
	"piece_FallenRocks": "res://scenes/supplied/FallenRocks.tscn",
	"piece_LanternPost": "res://scenes/supplied/LanternPost.tscn",
	"piece_LanternHook": "res://scenes/supplied/LanternHook.tscn",
	"piece_MushroomRed": "res://scenes/supplied/MushroomRed.tscn",
	"piece_MushroomSmall": "res://scenes/supplied/MushroomSmall.tscn",
	"piece_MushroomBlue": "res://scenes/supplied/MushroomBlue.tscn",
	"piece_Barrel": "res://scenes/supplied/Barrel.tscn",
	"piece_CloudWide": "res://scenes/supplied/CloudWide.tscn",
	"piece_CloudLong": "res://scenes/supplied/CloudLong.tscn",
	"piece_CloudSmall": "res://scenes/supplied/CloudSmall.tscn",
	"piece_CloudPair": "res://scenes/supplied/CloudPair.tscn",
	"piece_WaterfallWide": "res://scenes/supplied/WaterfallWide.tscn",
	"piece_WaterfallMedium": "res://scenes/supplied/WaterfallMedium.tscn",
	"piece_WaterfallSlim": "res://scenes/supplied/WaterfallSlim.tscn",
	"piece_WaterfallThin": "res://scenes/supplied/WaterfallThin.tscn",
	"piece_SplashWide": "res://scenes/supplied/SplashWide.tscn",
	"piece_SplashSmall": "res://scenes/supplied/SplashSmall.tscn",
	"piece_Foam": "res://scenes/supplied/Foam.tscn",
	"piece_RiverSurface": "res://scenes/supplied/RiverSurface.tscn",
	"piece_RiverLeft": "res://scenes/supplied/RiverLeft.tscn",
	"piece_RiverMiddle": "res://scenes/supplied/RiverMiddle.tscn",
	"piece_RiverRight": "res://scenes/supplied/RiverRight.tscn",
	"piece_FallsLongThin": "res://scenes/supplied/FallsLongThin.tscn",
	"piece_FallsLongA": "res://scenes/supplied/FallsLongA.tscn",
	"piece_FallsLongWide": "res://scenes/supplied/FallsLongWide.tscn",
	"piece_FallsLongB": "res://scenes/supplied/FallsLongB.tscn",
	"piece_FallsLongLarge": "res://scenes/supplied/FallsLongLarge.tscn",
	"piece_FallsBodyA": "res://scenes/supplied/FallsBodyA.tscn",
	"piece_FallsBodyB": "res://scenes/supplied/FallsBodyB.tscn",
	"piece_FallsBodyC": "res://scenes/supplied/FallsBodyC.tscn",
	"piece_FallsMist": "res://scenes/supplied/FallsMist.tscn",
	"piece_WaterIslandLeft": "res://scenes/supplied/WaterIslandLeft.tscn",
	"piece_WaterIslandWide": "res://scenes/supplied/WaterIslandWide.tscn",
	"piece_WaterIslandRight": "res://scenes/supplied/WaterIslandRight.tscn",
	"piece_WaterIslandSlim": "res://scenes/supplied/WaterIslandSlim.tscn",
	"piece_FallsIsland": "res://scenes/supplied/FallsIsland.tscn",
	"piece_FallsTwinIsland": "res://scenes/supplied/FallsTwinIsland.tscn",
	"piece_FallsWideIsland": "res://scenes/supplied/FallsWideIsland.tscn",
	"piece_FallsMossIsland": "res://scenes/supplied/FallsMossIsland.tscn",
	"piece_FallsStoneIsland": "res://scenes/supplied/FallsStoneIsland.tscn",
	"piece_FallsRock": "res://scenes/supplied/FallsRock.tscn",
	"piece_FallsStarRock": "res://scenes/supplied/FallsStarRock.tscn",
	"piece_FallsSteps": "res://scenes/supplied/FallsSteps.tscn",
	"piece_RockShards": "res://scenes/supplied/RockShards.tscn",
	"piece_RockShardsTall": "res://scenes/supplied/RockShardsTall.tscn",
	"piece_ArchDecor": "res://scenes/supplied/ArchDecor.tscn",
	"piece_BoulderMoss": "res://scenes/supplied/BoulderMoss.tscn",
	"piece_BoulderRound": "res://scenes/supplied/BoulderRound.tscn",
	"piece_BoulderSmall": "res://scenes/supplied/BoulderSmall.tscn",
	"piece_RockAngular": "res://scenes/supplied/RockAngular.tscn",
	"piece_RockSmall": "res://scenes/supplied/RockSmall.tscn",
	"piece_Pebble": "res://scenes/supplied/Pebble.tscn",
	"piece_RockPatch": "res://scenes/supplied/RockPatch.tscn",
	"piece_BushLow": "res://scenes/supplied/BushLow.tscn",
	"piece_BushLowFlowers": "res://scenes/supplied/BushLowFlowers.tscn",
	"piece_StarDecorLarge": "res://scenes/supplied/StarDecorLarge.tscn",
	"piece_StarDecorMedium": "res://scenes/supplied/StarDecorMedium.tscn",
	"piece_StarDecorSmall": "res://scenes/supplied/StarDecorSmall.tscn",
	"piece_StarDecorTilt": "res://scenes/supplied/StarDecorTilt.tscn",
	"piece_ShootingStar": "res://scenes/supplied/ShootingStar.tscn",
	"piece_StarTrail": "res://scenes/supplied/StarTrail.tscn",
	"piece_CrateOrnate": "res://scenes/supplied/CrateOrnate.tscn",
	"piece_LanternHanging": "res://scenes/supplied/LanternHanging.tscn",
	"piece_LanternPostSmall": "res://scenes/supplied/LanternPostSmall.tscn",
	"piece_VineRight": "res://scenes/supplied/VineRight.tscn",
	"piece_CloudPuff": "res://scenes/supplied/CloudPuff.tscn",
	"piece_CloudLow": "res://scenes/supplied/CloudLow.tscn",
	"piece_IslandGarden": "res://scenes/supplied/IslandGarden.tscn",
	"piece_WaterIslandTall": "res://scenes/supplied/WaterIslandTall.tscn",
	"piece_WaterIslandTiny": "res://scenes/supplied/WaterIslandTiny.tscn",
	"piece_WaterIslandEdge": "res://scenes/supplied/WaterIslandEdge.tscn",
	"piece_TwinWaterIsland": "res://scenes/supplied/TwinWaterIsland.tscn",
	"piece_ThinWaterIsland": "res://scenes/supplied/ThinWaterIsland.tscn",
	"piece_RoundWaterIsland": "res://scenes/supplied/RoundWaterIsland.tscn",
	"piece_WaterfallNarrow": "res://scenes/supplied/WaterfallNarrow.tscn",
	"piece_SplashRight": "res://scenes/supplied/SplashRight.tscn",
	"piece_DropsWide": "res://scenes/supplied/DropsWide.tscn",
	"piece_DropsTall": "res://scenes/supplied/DropsTall.tscn",
	"piece_Drop": "res://scenes/supplied/Drop.tscn",
	"piece_DropsPair": "res://scenes/supplied/DropsPair.tscn",
	"piece_FoamMedium": "res://scenes/supplied/FoamMedium.tscn",
	"piece_FoamWide": "res://scenes/supplied/FoamWide.tscn",
	"piece_FoamSmall": "res://scenes/supplied/FoamSmall.tscn",
	"piece_RiverSurfaceMedium": "res://scenes/supplied/RiverSurfaceMedium.tscn",
	"piece_RiverSurfaceShort": "res://scenes/supplied/RiverSurfaceShort.tscn",
	"piece_RiverSurfaceSmall": "res://scenes/supplied/RiverSurfaceSmall.tscn",
	"piece_RiverSurfaceTiny": "res://scenes/supplied/RiverSurfaceTiny.tscn",
	"piece_FallsNarrowIsland": "res://scenes/supplied/FallsNarrowIsland.tscn",
	"piece_FallsIslandEdge": "res://scenes/supplied/FallsIslandEdge.tscn",
	"piece_FallsWallIsland": "res://scenes/supplied/FallsWallIsland.tscn",
	"piece_FallsGardenIsland": "res://scenes/supplied/FallsGardenIsland.tscn",
	"piece_FallsSmallIsland": "res://scenes/supplied/FallsSmallIsland.tscn",
	"piece_FallsTinyIsland": "res://scenes/supplied/FallsTinyIsland.tscn",
	"piece_FallsLongNeedle": "res://scenes/supplied/FallsLongNeedle.tscn",
	"piece_FallsBodyD": "res://scenes/supplied/FallsBodyD.tscn",
	"piece_FallsBodyE": "res://scenes/supplied/FallsBodyE.tscn",
	"piece_FallsBodyF": "res://scenes/supplied/FallsBodyF.tscn",
	"piece_FallsDropsA": "res://scenes/supplied/FallsDropsA.tscn",
	"piece_FallsDropsB": "res://scenes/supplied/FallsDropsB.tscn",
	"piece_FallsDropsC": "res://scenes/supplied/FallsDropsC.tscn"
}
var kit_instance:Node2D
var used := false
var time := 0.0
var repair := 0.0
var label: Label
var talking:=false
var dialogue_time:=0.0
var narrator:AnimatedSprite2D
var gate_open:=false
var portal:AnimatedSprite2D
var opening_started:=false
const COLLECTIBLE_TEXTURES = {
	"star_key":preload("res://assets/worldkit/star_key.tres"),
	"crystal":preload("res://assets/worldkit/crystal.tres")
}
func _refresh_kit() -> void:
	if is_instance_valid(kit_instance):
		remove_child(kit_instance);kit_instance.queue_free();kit_instance=null
	if kind=="asset_piece" and asset_scene!=null:
		kit_instance=asset_scene.instantiate()
		add_child(kit_instance)
	elif KIT_SCENES.has(kind):
		var scene:PackedScene=load(KIT_SCENES[kind])
		kit_instance=scene.instantiate()
		add_child(kit_instance)
		if kind=="crate":kit_instance.position.y=-76
		elif kind=="stone_block":kit_instance.position.y=-88
	if narrator:narrator.visible=kind=="mole"
func _ready() -> void:
	_refresh_kit()
	if kind=="goal":
		portal=AnimatedSprite2D.new()
		portal.sprite_frames=preload("res://assets/animations/portal_shackles.tres")
		portal.position=Vector2(-20 if gate_flip else 20,-38)*gate_scale
		portal.scale=Vector2(0.245,0.24)*gate_scale
		portal.z_index=-1
		portal.visible=false
		add_child(portal)
		portal.animation_finished.connect(func():
			if portal.animation==&"opening":portal.play("portal"))
	narrator=get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if Engine.is_editor_hint(): return
	add_to_group("objects")
func _process(delta: float) -> void:
	time+=delta
	queue_redraw()
	if Engine.is_editor_hint(): return
	var level=get_tree().get_first_node_in_group("level")
	gate_open=level!=null and level.star_collected and not level.boss_alive
	if portal:
		portal.visible=gate_open and kind=="goal"
		if gate_open and not opening_started:
			opening_started=true;portal.play("opening")
	var player=get_tree().get_first_node_in_group("player")
	if player==null: return
	var d:float=global_position.distance_to(player.global_position)
	talking=false
	if kind=="checkpoint" and not used and d<90:
		used=true;get_tree().call_group("level","set_checkpoint",global_position)
		Progress.sfx("checkpoint")
	elif kind in ["star_key","crystal"] and not used and d<62:
		used=true
		if player.has_method("celebrate_collect"):player.celebrate_collect(kind,global_position)
		else:player.happy=0.65
		if kind=="star_key":
			if level:level.star_collected=true
			Progress.sfx("repair")
		else:
			get_tree().call_group("game","collect_crystal")
			Progress.sfx("gold")
	elif kind=="mole" and d<230:
		dialogue_time+=delta
		var pages:=message.split("\n\n",false)
		if not pages.is_empty():
			var page:=pages[int(dialogue_time/7.5)%pages.size()]
			get_tree().call_group("game","speak",self,page,"voice_mole")
			var game=get_tree().get_first_node_in_group("game")
			talking=game!=null and game.speaker==self and game.speech_progress<page.length()
	elif kind=="mole":dialogue_time=0.0
	elif kind=="fouk" and not used and d<110:
		repair+=delta;player.frozen=true
		get_tree().call_group("game","hint","Bit opravuje Fouka… ✦")
		if repair>2.0:
			used=true;player.frozen=false;player.has_fouk=true;player.happy=1.0
			get_tree().call_group("game","hint","Fouk je zpátky! Ve vzduchu stiskni skok ještě jednou.")
			Progress.sfx("repair")
	if narrator:
		narrator.play("talk" if talking else "idle")
		if kind=="mole" and absf(player.global_position.x-global_position.x)>12:
			narrator.flip_h=player.global_position.x<global_position.x
func _draw() -> void:
	if used and kind in ["fouk","star_key","crystal"]: return
	match kind:
		"checkpoint":
			draw_texture_rect(DreamArt.texture("flag"),Rect2(-29,-116,72,116),false,Color("ffffff") if used else Color("b4c8df"))
			if used: draw_circle(Vector2(5,-120),7,Color("fff49b"))
		"star_key","crystal":
			var texture:Texture2D=COLLECTIBLE_TEXTURES[kind]
			var size:=64.0 if kind=="star_key" else 56.0
			draw_texture_rect(texture,Rect2(-size/2,-size/2+sin(time*3)*3,size,size),false)
		"goal":
			draw_set_transform(Vector2.ZERO,0,Vector2(-gate_scale if gate_flip else gate_scale,gate_scale))
			var color:=Color.WHITE if gate_open else Color(0.62,0.67,0.78)
			draw_texture_rect(DreamArt.texture("arch"),Rect2(-60,-125,150,125),false,color)
			draw_set_transform(Vector2.ZERO)
		"mole":
			pass # Native AnimatedSprite2D renders the narrator.
		"jiskra","fouk":
			var h:=150.0 if kind=="mole" else 90.0
			var bob:=sin(time*3)*3 if kind!="mole" else 0.0
			var sway:=sin(time*10)*0.023 if talking else sin(time*2)*0.006
			draw_set_transform(Vector2(0,bob+(5.0 if kind=="mole" else 0.0)),sway,Vector2(1.0,1.0+sin(time*(10 if talking else 2))*0.012))
			draw_texture_rect(DreamArt.texture(kind),Rect2(-h/2,-h,h,h),false)
			draw_set_transform(Vector2.ZERO)
			if kind=="fouk" and repair>0:
				for i in range(3):
					var a:=time*6+i*TAU/3
					draw_texture_rect(DreamArt.texture("star"),Rect2(cos(a)*42-8,-45+sin(a)*24,16,16),false)
		"arch": draw_texture_rect(DreamArt.texture("arch"),Rect2(-75,-120,150,120),false)
		"bush": draw_texture_rect(DreamArt.texture("bush"),Rect2(-60,-65,120,75),false)


func touches_portal(from_feet:Vector2,to_feet:Vector2) -> bool:
	if kind!="goal" or portal==null:return false
	var rect:=Rect2(portal.position-Vector2(26,36)*gate_scale,Vector2(52,72)*gate_scale)
	rect=rect.grow_individual(19,37,19,37)
	var a:=to_local(from_feet-Vector2(0,37))
	var b:=to_local(to_feet-Vector2(0,37))
	if rect.has_point(a) or rect.has_point(b):return true
	var corners=[rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)]
	for i in range(4):
		if Geometry2D.segment_intersects_segment(a,b,corners[i],corners[(i+1)%4])!=null:return true
	return false

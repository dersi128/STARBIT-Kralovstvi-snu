class_name DreamArt
extends RefCounted
static var cache: Dictionary = {}
static var rects := {
 "idle":Rect2(300,10,205,338), "front":Rect2(25,10,240,338),
 "run1":Rect2(508,12,235,338), "run2":Rect2(745,12,232,338),
 "run3":Rect2(980,12,225,338), "run4":Rect2(1207,12,238,338),
 "jump":Rect2(50,402,264,306), "fall":Rect2(366,425,296,283),
 "happy":Rect2(145,755,291,270), "hurt":Rect2(995,757,278,266),
 "ground":Rect2(208,44,260,153), "island":Rect2(26,433,300,156),
 "small":Rect2(800,445,147,141), "stone":Rect2(965,434,140,150),
 "arch":Rect2(16,477,305,226), "flag":Rect2(375,7,217,323),
 "bush":Rect2(18,330,228,160), "star":Rect2(780,889,106,108),
 "cloud":Rect2(310,713,281,110), "mole":Rect2(25,45,280,275),
 "rock_enemy":Rect2(368,45,291,275), "cloud_enemy":Rect2(711,58,294,255),
 "boss":Rect2(5,338,366,318), "fouk":Rect2(400,360,250,261), "jiskra":Rect2(735,397,237,223)
}
static func texture(key: String) -> Texture2D:
 if cache.has(key): return cache[key]
 if key.begins_with("push"):
  cache[key]=load("res://assets/animations/"+key+".tres")
  return cache[key]
 if ResourceLoader.exists("res://assets/pieces/"+key+".png"):
  cache[key]=load("res://assets/pieces/"+key+".png")
  return cache[key]
 var file := "bit"
 if key in ["ground","island","small","stone"]: file="platforms"
 elif key in ["arch","flag","bush","star","cloud"]: file="props"
 elif key in ["mole","rock_enemy","cloud_enemy","boss","fouk","jiskra"]: file="cast"
 var a := AtlasTexture.new()
 a.atlas = load("res://assets/"+file+".png")
 a.region = rects[key]
 a.filter_clip = true
 cache[key]=a
 return a
static func material() -> ShaderMaterial:
 var m := ShaderMaterial.new()
 m.shader=load("res://assets/cutout.gdshader")
 return m
static func set_sprite(sprite: Sprite2D, key: String, height: float) -> void:
 sprite.texture=texture(key)
 var size: Vector2 = sprite.texture.get_size()
 sprite.scale=Vector2.ONE*(height/size.y)

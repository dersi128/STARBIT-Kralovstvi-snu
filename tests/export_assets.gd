extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 DirAccess.make_dir_recursive_absolute("res://assets/pieces")
 for key in DreamArt.rects:
  var tex:Texture2D
  if key in ["mole","rock_enemy","cloud_enemy","boss","fouk","jiskra"]:
   var atlas:=AtlasTexture.new();atlas.atlas=load("res://assets/cast.png");atlas.region=DreamArt.rects[key];atlas.filter_clip=true;tex=atlas
  else:continue
  var viewport:=SubViewport.new()
  viewport.size=Vector2i(tex.get_size())
  viewport.transparent_bg=true
  viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
  root.add_child(viewport)
  var sprite:=Sprite2D.new()
  sprite.texture=tex;sprite.centered=false
  if key in ["mole","rock_enemy","cloud_enemy","boss","fouk","jiskra"]:sprite.material=DreamArt.material()
  viewport.add_child(sprite)
  await process_frame
  await RenderingServer.frame_post_draw
  viewport.get_texture().get_image().save_png("res://assets/pieces/"+key+".png")
  viewport.queue_free()
 print("Exported ",DreamArt.rects.size()," isolated sprites")
 quit()

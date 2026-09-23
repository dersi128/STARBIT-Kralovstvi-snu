extends SceneTree
func _initialize():call_deferred("run")
func run():
 var bg:=ColorRect.new();bg.color=Color("299acc");bg.size=Vector2(1280,720);root.add_child(bg)
 var frames=load("res://assets/animations/mole.tres")
 for i in 8:
  var sprite:=Sprite2D.new();sprite.texture=frames.get_frame_texture("idle" if i<4 else "talk",i%4)
  sprite.scale=Vector2(0.6,0.6);sprite.position=Vector2(160+(i%4)*310,180+(i/4)*320);root.add_child(sprite)
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://verification/mole-fix.png")
 quit()

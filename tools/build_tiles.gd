extends SceneTree
func _initialize():call_deferred("run")
func run():
 var tiles:=TileSet.new();tiles.tile_size=Vector2i(128,128);tiles.add_physics_layer();tiles.set_physics_layer_collision_layer(0,1)
 var source:=TileSetAtlasSource.new();source.texture=load("res://assets/worldkit/ground_tiles.png");source.texture_region_size=Vector2i(128,128)
 tiles.add_source(source,0)
 for i in 2:
  source.create_tile(Vector2i(i,0))
  var data:=source.get_tile_data(Vector2i(i,0),0)
  data.set_collision_polygons_count(0,1)
  data.set_collision_polygon_points(0,0,PackedVector2Array([Vector2(-64,-64),Vector2(64,-64),Vector2(64,64),Vector2(-64,64)]))
 ResourceSaver.save(tiles,"res://assets/worldkit/GroundTiles.tres")
 var layer:=TileMapLayer.new();layer.name="PaintGround";layer.tile_set=tiles
 for x in 6:layer.set_cell(Vector2i(x,0),0,Vector2i(x%2,0))
 var scene:=PackedScene.new();scene.pack(layer);ResourceSaver.save(scene,"res://scenes/worldkit/PaintGround.tscn")
 layer.free();quit()

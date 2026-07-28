@tool
extends EditorScript

func _run() -> void:
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("assets"):
		dir.make_dir("assets")
		
	var img = Image.create(128, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.478, 0.702, 0.302)) # Grass (0,0)
	img.fill_rect(Rect2i(32, 0, 32, 32), Color(0.643, 0.486, 0.282)) # Dirt (1,0)
	img.fill_rect(Rect2i(64, 0, 32, 32), Color(0.255, 0.651, 0.965)) # Water (2,0)
	img.fill_rect(Rect2i(96, 0, 32, 32), Color(0.133, 0.545, 0.133)) # Bush (3,0)
	img.fill_rect(Rect2i(0, 32, 32, 32), Color(1.0, 0.843, 0.0)) # Corn (0,1)
	img.fill_rect(Rect2i(32, 32, 32, 32), Color(0.545, 0.271, 0.075)) # Wood (1,1)
	img.fill_rect(Rect2i(64, 32, 32, 32), Color(0.5, 0.5, 0.5)) # Stone (2,1)
	
	img.save_png("res://assets/tiles.png")
	print("Saved tiles.png")
	
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	
	tileset.add_physics_layer()
	
	var source = TileSetAtlasSource.new()
	source.texture = load("res://assets/tiles.png") # Must load as texture resource
	if source.texture == null:
		# Fallback if load fails during script execution
		source.texture = ImageTexture.create_from_image(img)
		
	source.texture_region_size = Vector2i(32, 32)
	
	for y in range(2):
		for x in range(4):
			if y == 1 and x == 3: continue
			source.create_tile(Vector2i(x, y))
			
	var solid_tiles = [Vector2i(2,0), Vector2i(1,1), Vector2i(2,1)]
	for coords in solid_tiles:
		var tile_data = source.get_tile_data(coords, 0)
		tile_data.add_collision_polygon(0)
		tile_data.set_collision_polygon_points(0, 0, [
			Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)
		])
	
	tileset.add_source(source, 0)
	
	ResourceSaver.save(tileset, "res://tileset.tres")
	print("Tileset generated successfully at res://tileset.tres")

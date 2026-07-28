@tool
extends EditorScript

func _run() -> void:
	var level = Node2D.new()
	level.name = "Level"
	level.set_script(load("res://scripts/managers/level_manager.gd"))
	
	var tm = TileMapLayer.new()
	tm.name = "TileMapLayer"
	tm.tile_set = load("res://tileset.tres")
	level.add_child(tm)
	tm.owner = level
	
	for y in range(40):
		for x in range(60):
			var atlas = Vector2i(0, 0) # grass
			
			if (y == 15 or y == 16) and x >= 10 and x < 50:
				atlas = Vector2i(1, 0)
			elif (x == 30 or x == 31) and y >= 5 and y < 35:
				atlas = Vector2i(1, 0)
			
			if (x-14)*(x-14) + (y-29)*(y-29) < 20:
				atlas = Vector2i(2, 0)
				
			if x >= 40 and x <= 51 and y >= 8 and y <= 13:
				if y == 8 or y == 13 or x == 40 or x == 51:
					atlas = Vector2i(1, 1) # wood
					
			if x >= 10 and x < 50 and (x % 4 != 0):
				if y == 2 or y == 37: atlas = Vector2i(1, 1)
			if y >= 2 and y < 38 and (y % 4 != 0):
				if x == 5 or x == 55: atlas = Vector2i(1, 1)
				
			if x >= 40 and x < 48 and y >= 20 and y < 28:
				atlas = Vector2i(0, 1) # corn
				
			if (x == 28 or x == 33) and (y == 15 or y == 16):
				atlas = Vector2i(2, 1) # stone
				
			tm.set_cell(Vector2i(x, y), 0, atlas)
			
	var hs_node = Node2D.new()
	hs_node.name = "HidingSpots"
	level.add_child(hs_node)
	hs_node.owner = level
	
	var hs_scene = load("res://scenes/environment/HidingSpot.tscn")
	var hs_coords = [Vector2(12, 10), Vector2(14, 10), Vector2(12, 12), Vector2(35, 30), Vector2(37, 30), Vector2(25, 12), Vector2(25, 20)]
	for i in range(hs_coords.size()):
		var hs = hs_scene.instantiate()
		hs.name = "HidingSpot%d" % i
		hs.position = hs_coords[i] * 32.0
		hs_node.add_child(hs)
		hs.owner = level
		
	var sp_scene = load("res://scenes/managers/SpawnPoint.tscn")
	var spawns = [
		[0, 30, 15],
		[1, 33, 15],
		[2, 10, 10],
		[2, 45, 30],
		[2, 10, 30],
		[3, 30, 20]
	]
	for i in range(spawns.size()):
		var sp = sp_scene.instantiate()
		sp.name = "SpawnPoint%d" % i
		sp.spawn_type = spawns[i][0]
		sp.position = Vector2(spawns[i][1] * 32.0, spawns[i][2] * 32.0)
		level.add_child(sp)
		sp.owner = level
		
	var scene = PackedScene.new()
	scene.pack(level)
	ResourceSaver.save(scene, "res://scenes/environment/Level.tscn")
	print("Level built successfully")

extends SceneTree
func _init():
	var scene = preload("res://assets/maps/ChickenGangMap.tmx").instantiate()
	var collision_node = scene.get_node_or_null("collision")
	
	var tall_layers = []
	for child in scene.get_children():
		if child.get_class() == "TileMapLayer":
			var ln = child.name.to_lower()
			if ln in ["buildings", "tall_buildings", "trees up", "trees down"]:
				tall_layers.append(child)
				
	var vision_blockers = 0
	var low_obstacles = 0
	
	if collision_node:
		for child in collision_node.get_children():
			if child is StaticBody2D:
				var is_tall = false
				
				# Get center of shape
				var center = child.global_position
				var shape = child.get_child(0)
				if shape and shape is CollisionShape2D and shape.shape is RectangleShape2D:
					center += shape.position
					
				for tl in tall_layers:
					var map_pos = tl.local_to_map(tl.to_local(center))
					if tl.get_cell_source_id(map_pos) != -1:
						is_tall = true
						break
				
				if is_tall:
					vision_blockers += 1
				else:
					low_obstacles += 1
					
	print("Vision Blockers: ", vision_blockers)
	print("Low Obstacles (Fences, Water, etc.): ", low_obstacles)
	quit()

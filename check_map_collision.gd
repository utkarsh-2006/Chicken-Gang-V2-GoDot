extends SceneTree

func _init() -> void:
	print("Checking Level collision layers...")
	var scene = load("res://assets/maps/ChickenGangMap.tscn")
	if not scene:
		print("Checking main.tscn for LevelManager...")
		scene = load("res://main.tscn")
		var instance = scene.instantiate()
		var lm = instance.get_node_or_null("Level")
		if lm and lm.world_scene:
			var world = lm.world_scene.instantiate()
			print("World loaded. Checking StaticBody2D nodes...")
			_check_nodes(world)
		else:
			print("LevelManager not found or world_scene missing")
	else:
		var instance = scene.instantiate()
		_check_nodes(instance)
		
	quit()

func _check_nodes(node: Node) -> void:
	if node is StaticBody2D:
		print("StaticBody2D found: ", node.name, " layer=", node.collision_layer, " mask=", node.collision_mask)
	elif node is TileMap or node is TileMapLayer:
		print("TileMap found: ", node.name, " layer=", node.collision_layer, " mask=", node.collision_mask)
	
	for child in node.get_children():
		_check_nodes(child)

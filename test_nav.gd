extends SceneTree

func _init() -> void:
	print("Testing NavMesh baking...")
	
	var main_scene = load("res://main.tscn")
	if not main_scene:
		print("Failed to load main.tscn")
		quit()
		return
		
	var root = main_scene.instantiate()
	var level = root.get_node("Level")
	
	# Simulate what LevelManager does
	var world_scene = load("res://assets/maps/ChickenGangMap.tmx")
	var world_instance = world_scene.instantiate()
	level.add_child(world_instance)
	
	# Test baking
	var nav_poly = NavigationPolygon.new()
	nav_poly.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	nav_poly.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_ROOT_NODE_CHILDREN
	nav_poly.agent_radius = 16.0
	
	var outline = PackedVector2Array([
		Vector2(-500, -500),
		Vector2(3000, -500),
		Vector2(3000, 3000),
		Vector2(-500, 3000)
	])
	nav_poly.add_outline(outline)
	
	var nav_region = NavigationRegion2D.new()
	nav_region.navigation_polygon = nav_poly
	level.add_child(nav_region)
	
	print("Baking...")
	
	# We need to run baking asynchronously or synchronously?
	# In Godot 4, bake_navigation_polygon() is asynchronous by default in the editor, but has a callback.
	# Actually, NavigationServer2D.bake_from_source_geometry_data() is the synchronous backend.
	# Or NavigationServer2D.parse_source_geometry_data()
	
	# Let's try synchronous bake
	NavigationServer2D.bake_from_source_geometry_data(nav_poly, NavigationMeshSourceGeometryData2D.new(), func(): 
		print("Bake callback fired!")
		pass
	)
	
	# Wait, `nav_region.bake_navigation_polygon()` works too. Let's just use the server manually to avoid scene tree await issues in a headless test.
	var source_data = NavigationMeshSourceGeometryData2D.new()
	NavigationServer2D.parse_source_geometry_data(nav_poly, source_data, level)
	NavigationServer2D.bake_from_source_geometry_data(nav_poly, source_data)
	
	var polys = nav_poly.get_polygon_count()
	print("Polygons baked: ", polys)
	
	quit()

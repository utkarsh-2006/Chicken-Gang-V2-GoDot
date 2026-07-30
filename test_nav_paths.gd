extends SceneTree

func _init() -> void:
	print("\n--- NAV PATH PROOF ---")
	
	var main_scene = load("res://main.tscn")
	var root = main_scene.instantiate()
	
	# Add to SceneTree so LevelManager _ready and _run_adapters fire
	root.name = "MainRoot"
	var current_scene = root
	get_root().add_child(root)
	
	# Wait for a few physics frames so _run_adapters finishes and NavigationServer syncs
	for i in range(20):
		await self.physics_frame
		
	# Force map sync just in case
	var map = root.get_world_2d().navigation_map
	NavigationServer2D.map_force_update(map)
	
	# Let's define some test points
	# Test A: Open space to open space
	# Let's assume (200, 200) to (500, 200) is open space.
	var pA1 = Vector2(200, 200)
	var pA2 = Vector2(500, 200)
	
	# Test B: One side of a major building to opposite side
	# E.g. A building is roughly near center. Let's use (1000, 1000) to (1200, 1200) if it crosses something
	var pB1 = Vector2(1000, 800)
	var pB2 = Vector2(1000, 1200)
	
	# Test C: Point inside solid collision
	# Tiled coordinates: (0,0) is likely off map or in a wall. (50, 50) might be a fence.
	# The map bounds are 0,0 to 2240, 2080.
	# We can query the closest point on the navmesh from (1000, 1000) and compare
	
	# Let's query paths!
	print("\nTEST A: Open space to open space (200,200) -> (500,200)")
	var pathA = NavigationServer2D.map_get_path(map, pA1, pA2, true)
	print("Path A length: ", pathA.size())
	if pathA.size() > 0: print("Start: ", pathA[0], " End: ", pathA[pathA.size()-1])
	
	print("\nTEST B: One side of building to another (1000,800) -> (1000,1200)")
	var pathB = NavigationServer2D.map_get_path(map, pB1, pB2, true)
	print("Path B length: ", pathB.size())
	if pathB.size() > 0: print("Start: ", pathB[0], " End: ", pathB[pathB.size()-1])
	
	print("\nTEST C: Point inside solid collision (-50, -50)")
	var pathC = NavigationServer2D.map_get_path(map, Vector2(-50, -50), Vector2(500, 500), true)
	print("Path C length: ", pathC.size())
	if pathC.size() > 0: print("Start: ", pathC[0], " End: ", pathC[pathC.size()-1])
	
	print("\n--- NAV PATH PROOF DONE ---")
	quit()

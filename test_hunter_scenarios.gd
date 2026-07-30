extends SceneTree

func _init() -> void:
	print("\n--- PHASE 12: RUNTIME SCENARIOS ---")
	
	var chicken_scene = load("res://scenes/entities/chicken/Chicken.tscn")
	var hunter_scene = load("res://scenes/entities/hunter/Hunter.tscn")
	
	var c = chicken_scene.instantiate()
	var h = hunter_scene.instantiate()
	
	var root = Node2D.new()
	get_root().add_child(root)
	
	# Add a static body representing a building for Scenario D
	var wall = StaticBody2D.new()
	wall.collision_layer = 1
	wall.collision_mask = 1
	var wall_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(20, 200)
	wall_shape.shape = rect
	wall.add_child(wall_shape)
	root.add_child(wall)
	wall.global_position = Vector2(50, 0)
	
	root.add_child(c)
	root.add_child(h)
	
	# We need a nav region for the Hunter so _navigate_towards works
	var nav = NavigationRegion2D.new()
	var poly = NavigationPolygon.new()
	poly.add_outline(PackedVector2Array([Vector2(-500,-500), Vector2(500,-500), Vector2(500,500), Vector2(-500,500)]))
	poly.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	nav.navigation_polygon = poly
	root.add_child(nav)
	
	# Wait for nav setup
	for i in range(10): await self.physics_frame
	
	# SCENARIO A — Open visibility
	print("\nSCENARIO A - Open visibility")
	h.global_position = Vector2(100, 0)
	c.global_position = Vector2(200, 0) # 100px away, unobstructed
	for i in range(5): await self.physics_frame
	print("LOS result: ", "HIT" if h.current_target == null else "CLEAR")
	print("Hunter state: ", h.State.keys()[h.current_state])
	if h.current_target == c:
		print("Target correctly acquired.")
	else:
		print("Target FAILED.")
		
	# SCENARIO B — Chase movement
	print("\nSCENARIO B - Chase movement")
	var start_pos = h.global_position
	# Run a few frames
	for i in range(30):
		h._physics_process(0.016)
		await self.physics_frame
	var new_pos = h.global_position
	var dist_moved = start_pos.distance_to(new_pos)
	print("Distance moved toward target: ", dist_moved)
	if dist_moved > 5.0:
		print("Hunter is moving correctly.")
		
	# SCENARIO C — Close range
	print("\nSCENARIO C - Close range")
	c.global_position = h.global_position + Vector2(25, 0) # Just inside 40px chase_stop_distance
	for i in range(5):
		h._physics_process(0.016)
		await self.physics_frame
	print("Velocity at close range: ", h.velocity)
	if h.velocity == Vector2.ZERO:
		print("Hunter stopped correctly.")
		
	# SCENARIO D — Building LOS
	print("\nSCENARIO D - Building LOS")
	h.global_position = Vector2(0, 0)
	c.global_position = Vector2(100, 0) # Wall is at x=50
	h.current_target = null
	h.current_state = h.State.PATROL
	for i in range(5):
		h._physics_process(0.016)
		await self.physics_frame
	print("Target after wall check: ", "NULL" if h.current_target == null else "ACQUIRED")
	
	# SCENARIO E — Hidden
	print("\nSCENARIO E - Hidden")
	h.global_position = Vector2(100, 50)
	c.global_position = Vector2(150, 50) # Unobstructed
	for i in range(5):
		h._physics_process(0.016)
		await self.physics_frame
	print("State before hide: ", h.State.keys()[h.current_state])
	
	# Simulate hide
	c.set_meta("hidden", true) # Simulate can_be_detected returning false
	# We must mock can_be_detected for the test if it relies on a hidden variable.
	# Actually, let's just swap its method or state. 
	c.visible = false 
	# Wait, Chicken.can_be_detected() probably checks a state variable.
	c.current_state = 6 # State.HIDDEN
	
	for i in range(5):
		h._physics_process(0.016)
		await self.physics_frame
	
	print("State after hide: ", h.State.keys()[h.current_state])
	print("Target after hide: ", "NULL" if h.current_target == null else "STILL TRACKING")
	
	print("\n--- SCENARIOS COMPLETE ---")
	quit()

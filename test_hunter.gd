extends SceneTree

func _init() -> void:
	print("\n--- PHASE 1: DIAGNOSTIC TEST ---")
	var chicken_scene = load("res://scenes/entities/chicken/Chicken.tscn")
	var hunter_scene = load("res://scenes/entities/hunter/Hunter.tscn")
	
	var c = chicken_scene.instantiate()
	var h = hunter_scene.instantiate()
	
	var root = Node2D.new()
	get_root().add_child(root)
	
	root.add_child(c)
	root.add_child(h)
	
	c.global_position = Vector2(0, 0)
	h.global_position = Vector2(50, 0)
	
	# Wait a frame for physics to register
	for i in range(5):
		await self.physics_frame
		
	print("Hunter position: ", h.global_position)
	print("Chicken position: ", c.global_position)
	
	var bodies = h.vision_area.get_overlapping_bodies()
	print("Overlapping bodies in VisionArea: ", bodies.size())
	for b in bodies:
		print("- ", b.get_class(), " name: ", b.name)
		
	# Check LOS Raycast manually
	var space_state = root.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(h.global_position, c.global_position, 1)
	query.exclude = [h.get_rid(), c.get_rid()]
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		print("LOS result: EMPTY (Unobstructed)")
	else:
		print("LOS result: HIT -> ", result.collider.name)
		
	# Now let's check what Hunter's internal _scan_for_targets does
	h._scan_for_targets()
	print("Hunter state after scan: ", h.State.keys()[h.current_state])
	if h.current_target != null:
		print("Hunter target: ", h.current_target.name)
	else:
		print("Hunter target: NULL")
		
	print("\n--- DIAGNOSTIC DONE ---")
	quit()

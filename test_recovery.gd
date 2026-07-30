extends SceneTree

func _init():
	var file = FileAccess.open("res://test_recovery_out.txt", FileAccess.WRITE)
	file.store_line("--- RECOVERY TEST ---")
	
	# Load scenes
	var chicken_scene = load("res://scenes/entities/chicken/Chicken.tscn")
	var hunter_scene = load("res://scenes/entities/hunter/Hunter.tscn")
	var animal_scene = load("res://scenes/entities/animal/AmbientAnimal.tscn")
	var hiding_scene = load("res://scenes/environment/HidingSpot.tscn")
	var worm_scene = load("res://scenes/entities/collectible/Worm.tscn")
	
	# Create environment
	var root = get_root()
	var env_tall = StaticBody2D.new()
	env_tall.collision_layer = 1
	var env_shape = CollisionShape2D.new()
	env_shape.shape = RectangleShape2D.new()
	env_shape.shape.size = Vector2(100, 100)
	env_tall.add_child(env_shape)
	env_tall.position = Vector2(200, 0)
	root.add_child(env_tall)
	
	var env_low = StaticBody2D.new()
	env_low.collision_layer = 2
	var env_low_shape = CollisionShape2D.new()
	env_low_shape.shape = RectangleShape2D.new()
	env_low_shape.shape.size = Vector2(100, 100)
	env_low.add_child(env_low_shape)
	env_low.position = Vector2(400, 0)
	root.add_child(env_low)
	
	# 1. Spawn Chicken
	var c = chicken_scene.instantiate()
	root.add_child(c)
	file.store_line("1. Chicken spawned. Layer: " + str(c.collision_layer) + " Mask: " + str(c.collision_mask))
	
	# Check groups
	if c.is_in_group("chicken"): file.store_line("Chicken is in group 'chicken'.")
	
	# 2. Spawn Worm
	var w = worm_scene.instantiate()
	root.add_child(w)
	w.position = Vector2(10, 0)
	file.store_line("Worm Mask: " + str(w.collision_mask))
	
	# 3. Spawn Animal
	var a = animal_scene.instantiate()
	root.add_child(a)
	file.store_line("Animal Layer: " + str(a.collision_layer) + " Mask: " + str(a.collision_mask))
	
	# 4. Spawn Hiding Spot
	var hs = hiding_scene.instantiate()
	root.add_child(hs)
	file.store_line("HidingSpot Mask: " + str(hs.collision_mask))
	
	# 5. Spawn Hunter
	var h = hunter_scene.instantiate()
	root.add_child(h)
	file.store_line("Hunter Body Layer: " + str(h.collision_layer) + " Mask: " + str(h.collision_mask))
	var va = h.get_node("VisionArea")
	file.store_line("Hunter Vision Mask: " + str(va.collision_mask))
	
	# Simulate physics tick to let Area2Ds register overlapping bodies
	for i in range(5):
		root._process(0.016)
		get_tree().process_frame.emit()
		
	# Manual collision checks using PhysicsTestMotionParameters2D
	var space = c.get_world_2d().direct_space_state
	
	# Chicken vs Env
	var pm = PhysicsTestMotionParameters2D.new()
	pm.from = c.global_transform
	pm.motion = Vector2(200, 0)
	var result = PhysicsTestMotionResult2D.new()
	var hit = PhysicsServer2D.body_test_motion(c.get_rid(), pm, result)
	file.store_line("Chicken vs Tall Env collide: " + str(hit))
	
	# Hunter vs Env
	pm.from = h.global_transform
	pm.motion = Vector2(200, 0)
	hit = PhysicsServer2D.body_test_motion(h.get_rid(), pm, result)
	file.store_line("Hunter vs Tall Env collide: " + str(hit))
	
	# Hunter vs Chicken
	pm.motion = Vector2(0, 0) # Already at same pos
	hit = PhysicsServer2D.body_test_motion(h.get_rid(), pm, result)
	file.store_line("Hunter vs Chicken collide (glue test): " + str(hit))
	
	# Animal vs Env
	pm.from = a.global_transform
	pm.motion = Vector2(200, 0)
	hit = PhysicsServer2D.body_test_motion(a.get_rid(), pm, result)
	file.store_line("Animal vs Tall Env collide: " + str(hit))
	
	# Hiding spot logic
	hs.position = c.position
	# Wait for Area2D
	for i in range(5):
		get_tree().process_frame.emit()
	
	file.store_line("Chicken Hidden state: " + str(c.current_state == 2)) # State.HIDDEN
	file.store_line("Chicken Opacity: " + str(c.get_node("AnimatedSprite2D").modulate.a))
	file.store_line("Chicken can_be_detected: " + str(c.can_be_detected()))
	
	# Hunter LOS Raycast
	var query = PhysicsRayQueryParameters2D.create(h.global_position, env_tall.global_position, 1)
	var ray_hit = space.intersect_ray(query)
	file.store_line("Hunter LOS vs Tall Env blocks: " + str(not ray_hit.is_empty()))
	
	query = PhysicsRayQueryParameters2D.create(h.global_position, env_low.global_position, 1)
	ray_hit = space.intersect_ray(query)
	file.store_line("Hunter LOS vs Low Env blocks: " + str(not ray_hit.is_empty()))
	
	file.close()
	quit()

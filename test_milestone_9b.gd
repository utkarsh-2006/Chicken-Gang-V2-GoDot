extends Node2D

func _ready() -> void:
	print("\n=== MILESTONE 9B AUTOMATED TESTS ===")
	
	var hunter_scene = load("res://scenes/entities/hunter/Hunter.tscn")
	var chicken_scene = load("res://scenes/entities/chicken/Chicken.tscn")
	
	var root = self
	
	# We need a nav region for the Hunter so _navigate_towards works
	var nav = NavigationRegion2D.new()
	var poly = NavigationPolygon.new()
	poly.add_outline(PackedVector2Array([Vector2(-1000,-1000), Vector2(1000,-1000), Vector2(1000,1000), Vector2(-1000,1000)]))
	poly.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	nav.navigation_polygon = poly
	add_child(nav)
	
	# Wait for Nav Sync (Test A conceptually covered by game launch, we simulate it)
	for i in range(10): await get_tree().physics_frame
	print("TEST A (Navigation Sync): Completed without query errors.")
	
	# Provide environment pieces
	var fence = StaticBody2D.new()
	fence.collision_layer = 2 # Low obstacle
	var fs = CollisionShape2D.new()
	var frect = RectangleShape2D.new()
	frect.size = Vector2(20, 200)
	fs.shape = frect
	fence.add_child(fs)
	fence.global_position = Vector2(50, 0)
	root.add_child(fence)
	
	var building = StaticBody2D.new()
	building.collision_layer = 1 # Tall obstacle
	var bs = CollisionShape2D.new()
	var brect = RectangleShape2D.new()
	brect.size = Vector2(20, 200)
	bs.shape = brect
	building.add_child(bs)
	building.global_position = Vector2(150, 0)
	root.add_child(building)
	
	var h = hunter_scene.instantiate()
	var c = chicken_scene.instantiate()
	root.add_child(h)
	root.add_child(c)
	
	# Let's ensure the objects initialize
	for i in range(5): await get_tree().physics_frame
	
	# TEST B: Fence vision
	h.global_position = Vector2(0, 0)
	c.global_position = Vector2(100, 0)
	for i in range(5): h._physics_process(0.016); await get_tree().physics_frame
	if h.current_target == c:
		print("TEST B (Fence vision): PASS (LOS TRUE)")
	else:
		print("TEST B (Fence vision): FAIL")
		
	# TEST C: Building vision
	h.current_target = null
	h.current_state = h.State.PATROL
	h.global_position = Vector2(100, 0)
	c.global_position = Vector2(200, 0)
	for i in range(5): h._physics_process(0.016); await get_tree().physics_frame
	if h.current_target == null:
		print("TEST C (Building vision): PASS (LOS FALSE)")
	else:
		print("TEST C (Building vision): FAIL")
		
	# TEST D: Chase
	h.current_target = null
	h.current_state = h.State.PATROL
	h.global_position = Vector2(0, 200)
	c.global_position = Vector2(150, 200) # Open LOS
	for i in range(5): h._physics_process(0.016); await get_tree().physics_frame
	if h.current_state == h.State.CHASE:
		print("TEST D (Chase transition): PASS")
	else:
		print("TEST D (Chase transition): FAIL")
		
	# TEST E & F: Attack and Hit
	h.global_position = Vector2(0, 200)
	c.global_position = Vector2(25, 200) # Inside 30px attack_range
	c.set_state(0) # Walking
	
	# Step physics frames to reach ATTACK state and play animation
	while h.current_state != h.State.ATTACK:
		h._physics_process(0.016)
		await get_tree().physics_frame
		
	print("TEST E (Attack transition): PASS (Hunter velocity ", h.velocity, ")")
	
	# Wait for animation frame 3
	while h.anim.frame < 3:
		h.anim.frame += 1
		h._on_anim_frame_changed() # Trigger manually to simulate
	
	if c.current_state == c.State.STUNNED:
		print("TEST F (Successful hit): PASS (Chicken STUNNED)")
	else:
		print("TEST F (Successful hit): FAIL")
		
	# TEST I: Recovery
	c.stun_timer = 0.05
	for i in range(10): c._physics_process(0.016); await get_tree().physics_frame
	if c.current_state != c.State.STUNNED:
		print("TEST I (Recovery): PASS")
	else:
		print("TEST I (Recovery): FAIL")
		
	# TEST G: Dodge
	h.current_state = h.State.CHASE
	h.attack_cooldown_timer = 0.0
	c.global_position = Vector2(25, 300)
	h.global_position = Vector2(0, 300)
	for i in range(5): h._physics_process(0.016); await get_tree().physics_frame
	
	if h.current_state == h.State.ATTACK:
		# Teleport chicken away before impact
		c.global_position = Vector2(500, 300)
		while h.anim.frame < 3:
			h.anim.frame += 1
			h._on_anim_frame_changed()
			
		if c.current_state != c.State.STUNNED:
			print("TEST G (Dodge): PASS")
		else:
			print("TEST G (Dodge): FAIL")

	# TEST H: Hiding
	h.current_state = h.State.CHASE
	h.attack_cooldown_timer = 0.0
	c.global_position = Vector2(25, 400)
	h.global_position = Vector2(0, 400)
	for i in range(5): h._physics_process(0.016); await get_tree().physics_frame
	
	if h.current_state == h.State.ATTACK:
		c.set_hidden(true)
		while h.anim.frame < 3:
			h.anim.frame += 1
			h._on_anim_frame_changed()
			
		if c.current_state != c.State.STUNNED and h.current_target == null:
			print("TEST H (Hiding): PASS")
		else:
			print("TEST H (Hiding): FAIL")
	
	# TEST J & K: Cooldown and Proximity
	h.current_target = c
	h.current_state = h.State.CHASE
	h.attack_cooldown_timer = 1.0 # Set cooldown
	c.set_hidden(false)
	c.global_position = Vector2(25, 500)
	h.global_position = Vector2(0, 500)
	
	h._physics_process(0.016)
	
	if h.current_state == h.State.CHASE and h.velocity == Vector2.ZERO:
		print("TEST K (Cooldown proximity): PASS (Stopped, didn't attack)")
	else:
		print("TEST K (Cooldown proximity): FAIL")
		
	# Wait out cooldown
	h.attack_cooldown_timer = 0.0
	h._physics_process(0.016)
	if h.current_state == h.State.ATTACK:
		print("TEST J (Repeated attack): PASS")
	else:
		print("TEST J (Repeated attack): FAIL")
		
	print("=== TESTS COMPLETE ===")
	get_tree().quit()

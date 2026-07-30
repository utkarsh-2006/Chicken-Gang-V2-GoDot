extends SceneTree
func _init():
	# 1. Update Hunter.tscn
	var h_scene = load("res://scenes/entities/hunter/Hunter.tscn")
	var h = h_scene.instantiate()
	var h_shape = h.get_node("CollisionShape2D")
	if h_shape.shape is CircleShape2D:
		h_shape.shape.radius = 10.0
	
	# Layer 8 (bit 3), mask 3 (environment layers 1 and 2)
	h.collision_layer = 8
	h.collision_mask = 3
	
	# Keep nav agent radius aligned
	var nav = h.get_node("NavigationAgent2D")
	if nav:
		nav.radius = 10.0
	
	var packed_h = PackedScene.new()
	packed_h.pack(h)
	ResourceSaver.save(packed_h, "res://scenes/entities/hunter/Hunter.tscn")
	
	# 2. Update Chicken.tscn (Layer 4, mask 3)
	var c_scene = load("res://scenes/entities/chicken/Chicken.tscn")
	var c = c_scene.instantiate()
	c.collision_layer = 4
	c.collision_mask = 3
	var packed_c = PackedScene.new()
	packed_c.pack(c)
	ResourceSaver.save(packed_c, "res://scenes/entities/chicken/Chicken.tscn")
	
	print("Hunter and Chicken collision fixed.")
	quit()

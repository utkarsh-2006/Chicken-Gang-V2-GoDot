extends Node
class_name WormManager

@export var worm_scene: PackedScene

var current_worms: int = 0

func _ready() -> void:
	randomize()
	SignalBus.spawn_dropped_worms.connect(_on_spawn_dropped_worms)

func initialize_map_spawns(spawn_data: Array) -> void:
	var space_state = get_tree().root.get_world_2d().direct_space_state
	var spawn_index = 0
	
	for data in spawn_data:
		spawn_index += 1
		if not data.get("enabled", true):
			continue
			
		var pos = data["position"]
		
		# Validation check
		var params = PhysicsPointQueryParameters2D.new()
		params.position = pos
		# We use mask 1 which usually corresponds to world collision
		params.collision_mask = 1 
		
		var results = space_state.intersect_point(params)
		var is_colliding = false
		for r in results:
			# If the point overlaps a StaticBody2D (e.g. wall/building)
			if r.collider is StaticBody2D:
				is_colliding = true
				break
				
		if is_colliding:
			push_warning("WARNING: Worm spawn " + str(spawn_index) + " overlaps world collision and was skipped.")
			continue
			
		_spawn_map_worm(data)

func _spawn_map_worm(data: Dictionary) -> void:
	if not worm_scene:
		return
		
	var worm = worm_scene.instantiate() as Worm
	worm.position = data["position"]
	
	var type_str = data.get("type", "common").to_lower()
	if type_str == "golden":
		worm.worm_type = Worm.WormType.GOLDEN
	elif type_str == "rare":
		worm.worm_type = Worm.WormType.RARE
	elif type_str == "event":
		worm.worm_type = Worm.WormType.EVENT
	else:
		worm.worm_type = Worm.WormType.COMMON
		
	var r_time = data.get("respawn_time", -1.0)
	if r_time > 0:
		worm.respawn_time = r_time
		
	# Permanent map worm (0 lifespan means it manages its own hide/respawn cycle)
	worm.lifespan = 0.0
	
	# We don't track current_worms decrement for map worms since they just hide, not queue_free
	add_child(worm)
	current_worms += 1

func _on_spawn_dropped_worms(amount: int, center_position: Vector2) -> void:
	for i in range(amount):
		if not worm_scene: return
		var worm = worm_scene.instantiate() as Worm
		
		var offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
		worm.position = center_position + offset
		
		# Temporary dropped worm
		worm.lifespan = 8.0
		worm.collect_delay = 1.0
		
		# It queue_frees itself when collected or timeout
		worm.tree_exited.connect(func(): current_worms -= 1)
		
		add_child(worm)
		current_worms += 1

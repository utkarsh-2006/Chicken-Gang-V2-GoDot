extends Node
class_name WormManager

@export var worm_scene: PackedScene
@export var target_map_worms: int = 20

var current_worms: int = 0
var spawn_zones: Array = []
var rejected_candidates_total: int = 0

func _ready() -> void:
	randomize()
	SignalBus.spawn_dropped_worms.connect(_on_spawn_dropped_worms)

func initialize_spawn_zones(zones: Array) -> void:
	spawn_zones = zones
	var successfully_spawned = 0
	rejected_candidates_total = 0
	
	print("WORM SPAWN SYSTEM")
	print("Zones discovered: ", zones.size())
	print("Target map worms: ", target_map_worms)
	
	if zones.size() == 0:
		push_warning("No worm spawn zones provided!")
		return
		
	for i in range(target_map_worms):
		if _spawn_random_worm():
			successfully_spawned += 1
			
	print("Successfully spawned: ", successfully_spawned)
	print("Rejected candidates: ", rejected_candidates_total)

func _spawn_random_worm() -> bool:
	var valid_pos = _get_random_valid_position()
	if valid_pos == Vector2.INF:
		return false
		
	var data = {
		"position": valid_pos,
		"type": "common",
		"enabled": true,
		"respawn_time": 15.0
	}
	
	_spawn_map_worm(data)
	return true

func _get_random_valid_position() -> Vector2:
	if spawn_zones.is_empty():
		return Vector2.INF
		
	var space_state = get_tree().root.get_world_2d().direct_space_state
	var max_attempts = 50
	
	for i in range(max_attempts):
		var zone: Rect2 = spawn_zones.pick_random()
		var candidate = Vector2(
			randf_range(zone.position.x, zone.position.x + zone.size.x),
			randf_range(zone.position.y, zone.position.y + zone.size.y)
		)
		
		# 1. Environment Collision Validation (Solid Objects)
		var env_shape = RectangleShape2D.new()
		env_shape.size = Vector2(20, 20) # 16x16 actual + 4px safety margin
		
		var env_params = PhysicsShapeQueryParameters2D.new()
		env_params.shape = env_shape
		env_params.transform = Transform2D(0, candidate)
		env_params.collision_mask = 1
		env_params.collide_with_areas = false
		env_params.collide_with_bodies = true
		
		var env_results = space_state.intersect_shape(env_params)
		var env_valid = true
		for r in env_results:
			if r.collider is StaticBody2D:
				env_valid = false
				break
				
		if not env_valid:
			rejected_candidates_total += 1
			continue
			
		# 2. Worm-to-Worm Spacing Validation (48px spacing)
		var worm_shape = CircleShape2D.new()
		worm_shape.radius = 24.0 # 48px diameter spacing
		
		var worm_params = PhysicsShapeQueryParameters2D.new()
		worm_params.shape = worm_shape
		worm_params.transform = Transform2D(0, candidate)
		worm_params.collision_mask = 1
		worm_params.collide_with_areas = true
		worm_params.collide_with_bodies = false
		
		var worm_results = space_state.intersect_shape(worm_params)
		var worm_valid = true
		for r in worm_results:
			if r.collider is Worm:
				worm_valid = false
				break
				
		if not worm_valid:
			rejected_candidates_total += 1
			continue
			
		return candidate
		
	push_warning("Failed to find valid worm spawn position after " + str(max_attempts) + " attempts.")
	return Vector2.INF

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
		
	var r_time = data.get("respawn_time", 15.0)
	if r_time > 0:
		worm.respawn_time = r_time
		
	# Permanent map worm (0 lifespan means it manages its own hide/respawn cycle)
	worm.lifespan = 0.0
	worm.map_worm_collected.connect(_on_map_worm_collected)
	
	add_child(worm)
	
func _on_map_worm_collected(worm: Worm) -> void:
	# Wait for the respawn delay, then attempt to give it a new valid position
	get_tree().create_timer(worm.respawn_time).timeout.connect(
		func():
			var new_pos = _get_random_valid_position()
			if new_pos != Vector2.INF:
				worm.position = new_pos
				worm.respawn()
			else:
				# If we fail, try again later so we don't spawn in a wall or 0,0
				_retry_respawn(worm)
	)

func _retry_respawn(worm: Worm) -> void:
	get_tree().create_timer(2.0).timeout.connect(
		func():
			var new_pos = _get_random_valid_position()
			if new_pos != Vector2.INF:
				worm.position = new_pos
				worm.respawn()
			else:
				_retry_respawn(worm)
	)

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

extends Node
class_name AnimalManager

enum AnimalType {
	CALF_BROWN,
	CALF_HOLSTEIN,
	CALF_WHITE,
	COW_BROWN,
	COW_HOLSTEIN,
	COW_WHITE,
	GOAT,
	LAMB,
	SHEEP,
	CAT_ORANGE
}

@export var target_animal_population: int = 12
@export var show_debug: bool = true

var animal_scene: PackedScene = preload("res://scenes/entities/animal/AmbientAnimal.tscn")
var spawn_zones: Array = []
var active_animals: Array = []

var spawn_weights = {
	AnimalType.CALF_BROWN: 10,
	AnimalType.CALF_HOLSTEIN: 10,
	AnimalType.CALF_WHITE: 10,
	AnimalType.COW_BROWN: 10,
	AnimalType.COW_HOLSTEIN: 10,
	AnimalType.COW_WHITE: 10,
	AnimalType.SHEEP: 10,
	AnimalType.LAMB: 10,
	AnimalType.GOAT: 5,
	AnimalType.CAT_ORANGE: 2
}

func initialize_spawn_zones(zones: Array) -> void:
	spawn_zones = zones
	if show_debug:
		print("Animal zones discovered: ", spawn_zones.size())
		print("Target population: ", target_animal_population)
	
	_spawn_initial_population()

func _spawn_initial_population() -> void:
	if spawn_zones.is_empty():
		if show_debug:
			print("No animal spawn zones available.")
		return
		
	var space_state = get_tree().root.get_world_2d().direct_space_state
	var spawned_count = 0
	var rejected_count = 0
	
	for i in range(target_animal_population):
		var type = _get_random_weighted_type()
		var valid_pos = _get_random_valid_position(space_state)
		
		if valid_pos != Vector2.INF:
			_spawn_animal(type, valid_pos)
			spawned_count += 1
		else:
			rejected_count += 1
			
	if show_debug:
		print("Animals successfully spawned: ", spawned_count)
		print("Rejected spawn candidates: ", rejected_count)

func _get_random_weighted_type() -> AnimalType:
	var total_weight = 0
	for weight in spawn_weights.values():
		total_weight += weight
		
	var roll = randi() % total_weight
	var current = 0
	
	for type in spawn_weights.keys():
		current += spawn_weights[type]
		if roll < current:
			return type
			
	return AnimalType.CALF_WHITE # Fallback

func _get_random_valid_position(space_state: PhysicsDirectSpaceState2D) -> Vector2:
	var max_attempts = 20
	
	for attempt in range(max_attempts):
		var zone: Rect2 = spawn_zones[randi() % spawn_zones.size()]
		var candidate = Vector2(
			randf_range(zone.position.x, zone.end.x),
			randf_range(zone.position.y, zone.end.y)
		)
		
		var params = PhysicsPointQueryParameters2D.new()
		params.position = candidate
		params.collision_mask = 1 | 8 # Environment + Animals
		
		var results = space_state.intersect_point(params)
		var collides = false
		for r in results:
			if r.collider is StaticBody2D or r.collider is CharacterBody2D:
				collides = true
				break
				
		if not collides:
			# Check against already spawned animals to maintain spacing
			for animal in active_animals:
				if is_instance_valid(animal) and candidate.distance_to(animal.global_position) < 40.0:
					collides = true
					break
					
			if not collides:
				return candidate
				
	return Vector2.INF

func _spawn_animal(type: AnimalType, pos: Vector2) -> void:
	var animal = animal_scene.instantiate()
	animal.global_position = pos
	
	# Pass configuration
	var config = _get_config_for_type(type)
	if animal.has_method("setup_animal"):
		animal.setup_animal(config)
		
	# Find rendering parent
	var level = get_node_or_null("../../Level")
	var tb = null
	if level and level.get_child_count() > 0:
		var world_instance = level.get_child(0)
		if world_instance:
			for i in range(world_instance.get_child_count()):
				var c = world_instance.get_child(i)
				if c.name == "tall_buildings":
					tb = c
					break
					
	var parent = tb if tb else get_parent()
	parent.add_child(animal)
	active_animals.append(animal)

func _get_config_for_type(type: AnimalType) -> Dictionary:
	var type_name = AnimalType.keys()[type].to_lower()
	var frames_path = "res://assets/entities/animals/" + type_name + "_frames.tres"
	var frames = load(frames_path)
	
	var is_cow = (type == AnimalType.COW_BROWN or type == AnimalType.COW_HOLSTEIN or type == AnimalType.COW_WHITE)
	var is_calf = (type == AnimalType.CALF_BROWN or type == AnimalType.CALF_HOLSTEIN or type == AnimalType.CALF_WHITE)
	var is_sheep = (type == AnimalType.SHEEP)
	var is_lamb = (type == AnimalType.LAMB)
	var is_goat = (type == AnimalType.GOAT)
	var is_cat = (type == AnimalType.CAT_ORANGE)
	
	var frame_size = 48 if is_cow else 32
	var col_offset_y = 20 if is_cow else 12
	
	var move_speed_min = 25.0
	var move_speed_max = 25.0
	var idle_min = 1.5
	var idle_max = 4.0
	var wander_min = 1.5
	var wander_max = 4.0
	var family_name = "UNKNOWN"
	
	if is_cow:
		family_name = "COW"
		move_speed_min = 18.0; move_speed_max = 22.0
		idle_min = 3.0; idle_max = 6.0
		wander_min = 1.5; wander_max = 3.0
	elif is_calf:
		family_name = "CALF"
		move_speed_min = 26.0; move_speed_max = 32.0
		idle_min = 1.5; idle_max = 3.5
		wander_min = 2.0; wander_max = 4.0
	elif is_sheep:
		family_name = "SHEEP"
		move_speed_min = 22.0; move_speed_max = 27.0
		idle_min = 2.0; idle_max = 4.0
		wander_min = 2.0; wander_max = 3.5
	elif is_lamb:
		family_name = "LAMB"
		move_speed_min = 28.0; move_speed_max = 34.0
		idle_min = 1.0; idle_max = 3.0
		wander_min = 2.0; wander_max = 4.0
	elif is_goat:
		family_name = "GOAT"
		move_speed_min = 30.0; move_speed_max = 36.0
		idle_min = 1.0; idle_max = 2.5
		wander_min = 3.0; wander_max = 5.0
	elif is_cat:
		family_name = "CAT"
		move_speed_min = 38.0; move_speed_max = 48.0
		idle_min = 3.0; idle_max = 7.0
		wander_min = 0.8; wander_max = 2.0
	
	var final_speed = randf_range(move_speed_min, move_speed_max)
	
	return {
		"frames": frames,
		"family_name": family_name,
		"frame_size": frame_size,
		"collision_size": Vector2(16, 8),
		"collision_offset": Vector2(0, col_offset_y),
		"move_speed": final_speed,
		"min_idle_duration": idle_min,
		"max_idle_duration": idle_max,
		"min_wander_duration": wander_min,
		"max_wander_duration": wander_max
	}

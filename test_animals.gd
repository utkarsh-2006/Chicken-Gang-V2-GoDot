extends SceneTree

func _init() -> void:
	print("\n--- DETERMINISTIC 10-ANIMAL TEST ---")
	
	var am_script = preload("res://scripts/managers/animal_manager.gd")
	var am = am_script.new()
	var scene = preload("res://scenes/entities/animal/AmbientAnimal.tscn")
	
	for type in range(10): # AnimalType 0 to 9
		var config = am._get_config_for_type(type)
		var type_name = am.AnimalType.keys()[type]
		
		var animal = scene.instantiate()
		animal.setup_animal(config)
		
		# We must manually trigger _ready since we're not adding to a tree
		animal._ready()
		
		var expected_frames_path = "res://assets/entities/animals/" + type_name.to_lower() + "_frames.tres"
		var actual_frames_path = animal.anim.sprite_frames.resource_path
		
		print("\nConfig: ", type_name)
		print("Expected frames: ", expected_frames_path)
		print("Actual frames: ", actual_frames_path)
		
		if expected_frames_path == actual_frames_path:
			print("Result: PASS")
		else:
			print("Result: FAIL")
			
	print("\n--- TEST COMPLETE ---\n")
	quit()

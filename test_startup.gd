extends SceneTree

func _init():
	var file = FileAccess.open("res://startup_test.txt", FileAccess.WRITE)
	file.store_line("--- STARTUP TEST ---")
	
	var main_scene = load("res://main.tscn")
	if not main_scene:
		file.store_line("ERROR: Cannot load main.tscn")
		quit()
		return
		
	var main = main_scene.instantiate()
	get_root().add_child(main)
	
	# Let it run for a bit to initialize LevelManager, GameManager, Spawns
	for i in range(10):
		get_root()._process(0.016)
		self.process_frame.emit()
		
	var gm = main.get_node_or_null("GameManager")
	if gm:
		file.store_line("GameManager found.")
		
	# Find chickens
	var chickens = self.get_nodes_in_group("chicken")
	file.store_line("Chickens spawned: " + str(chickens.size()))
	for c in chickens:
		file.store_line("- Chicken ID: " + str(c.get("player_id")))
		
	var worms = self.get_nodes_in_group("worm")
	file.store_line("Worms spawned: " + str(worms.size()))
	
	var animals = self.get_nodes_in_group("ambient_animal")
	file.store_line("Animals spawned: " + str(animals.size()))
	
	var hunters = self.get_nodes_in_group("hunter")
	file.store_line("Hunters spawned: " + str(hunters.size()))
	
	file.close()
	quit()

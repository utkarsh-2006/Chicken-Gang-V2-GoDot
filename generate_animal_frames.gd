extends SceneTree

func _init() -> void:
	print("Generating animal SpriteFrames...")
	
	var animals = {
		"calf_brown": 32,
		"calf_holstein": 32,
		"calf_white": 32,
		"cow_brown": 48,
		"cow_holstein": 48,
		"cow_white": 48,
		"goat": 32,
		"lamb": 32,
		"sheep": 32,
		"cat_orange": 32
	}
	
	for animal_name in animals.keys():
		var size = animals[animal_name]
		_generate_frames(animal_name, size)
		
	print("Done!")
	quit()

func _generate_frames(animal_name: String, size: int) -> void:
	var path = "res://assets/entities/animals/" + animal_name + ".png"
	var img = Image.new()
	var err = img.load(path)
	if err != OK:
		print("Failed to load image: ", path)
		return
		
	var tex = ImageTexture.create_from_image(img)
	var frames = SpriteFrames.new()
	var speed = 4.0
	var dir_names = ["down", "left", "right", "up"]
	
	for row in range(4):
		var d_name = dir_names[row]
		var y = row * size
		
		# idle (column 1)
		var idle_name = "idle_" + d_name
		frames.add_animation(idle_name)
		frames.set_animation_speed(idle_name, speed)
		frames.set_animation_loop(idle_name, true)
		var idle_atlas = AtlasTexture.new()
		idle_atlas.atlas = tex
		idle_atlas.region = Rect2(size, y, size, size)
		frames.add_frame(idle_name, idle_atlas)
		
		# walk (column 0, 1, 2, 1)
		var walk_name = "walk_" + d_name
		frames.add_animation(walk_name)
		frames.set_animation_speed(walk_name, speed)
		frames.set_animation_loop(walk_name, true)
		for col in [0, 1, 2, 1]:
			var walk_atlas = AtlasTexture.new()
			walk_atlas.atlas = tex
			walk_atlas.region = Rect2(col * size, y, size, size)
			frames.add_frame(walk_name, walk_atlas)
			
	frames.remove_animation("default")
	var out_path = "res://assets/entities/animals/" + animal_name + "_frames.tres"
	err = ResourceSaver.save(frames, out_path)
	if err == OK:
		print("Created: ", out_path)
	else:
		print("Failed to save: ", out_path)

extends SceneTree

func _init() -> void:
	var tex = load("res://assets/entities/animals/calf_white_32x32.png")
	if not tex:
		print("ERROR: Failed to load calf texture")
		quit()
		return
		
	var frames = SpriteFrames.new()
	var frame_w = 32
	var frame_h = 32
	var speed = 4.0
	
	var dir_names = ["down", "left", "right", "up"]
	
	for row in range(4):
		var d_name = dir_names[row]
		var y = row * frame_h
		
		# idle (column 1)
		var idle_name = "idle_" + d_name
		frames.add_animation(idle_name)
		frames.set_animation_speed(idle_name, speed)
		frames.set_animation_loop(idle_name, true)
		var idle_atlas = AtlasTexture.new()
		idle_atlas.atlas = tex
		idle_atlas.region = Rect2(32, y, frame_w, frame_h)
		frames.add_frame(idle_name, idle_atlas)
		
		# walk (column 0, 1, 2, 1)
		var walk_name = "walk_" + d_name
		frames.add_animation(walk_name)
		frames.set_animation_speed(walk_name, speed)
		frames.set_animation_loop(walk_name, true)
		for col in [0, 1, 2, 1]:
			var walk_atlas = AtlasTexture.new()
			walk_atlas.atlas = tex
			walk_atlas.region = Rect2(col * frame_w, y, frame_w, frame_h)
			frames.add_frame(walk_name, walk_atlas)
			
	# Remove default animation
	frames.remove_animation("default")
			
	var err = ResourceSaver.save(frames, "res://assets/entities/animals/calf_white_frames.tres")
	if err == OK:
		print("SUCCESS: calf_white_frames.tres created!")
	else:
		print("ERROR: Failed to save frames. Code: ", err)
		
	quit()

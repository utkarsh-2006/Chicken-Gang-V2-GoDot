extends SceneTree

func _init() -> void:
	print("Starting generation...")
	var img = Image.new()
	img.load("res://assets/entities/animals/calf_white_32x32.png")
	var tex = ImageTexture.create_from_image(img)
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
			
	frames.remove_animation("default")
	var err = ResourceSaver.save(frames, "res://assets/entities/animals/calf_white_frames.tres")
	if err != OK:
		print("ERROR: Failed to save frames. Code: ", err)
		
	# Now create the AmbientAnimal.tscn
	var root = CharacterBody2D.new()
	root.name = "AmbientAnimal"
	root.collision_layer = 0
	root.collision_mask = 1 # Solid environment only
	
	var anim = AnimatedSprite2D.new()
	anim.name = "AnimatedSprite2D"
	anim.sprite_frames = frames
	anim.animation = "idle_down"
	# Offset sprite slightly if needed, but we keep it 0,0 and offset the collision
	root.add_child(anim)
	anim.owner = root
	
	var coll = CollisionShape2D.new()
	coll.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(16, 8) # Small footprint
	coll.shape = shape
	coll.position = Vector2(0, 12) # Offset to bottom of 32x32 sprite
	root.add_child(coll)
	coll.owner = root
	
	# Attach script
	var script = load("res://scripts/entities/animal/ambient_animal.gd")
	if script:
		root.set_script(script)
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(root)
	err = ResourceSaver.save(packed_scene, "res://scenes/entities/animal/AmbientAnimal.tscn")
	
	if err == OK:
		print("SUCCESS: AmbientAnimal.tscn created!")
	else:
		print("ERROR saving scene: ", err)
		
	quit()

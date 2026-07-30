extends SceneTree
func _init():
	var frames: SpriteFrames = load("res://assets/hunter_frames.tres")
	if not frames:
		print("Failed to load hunter_frames.tres")
		quit()
		return

	var img = preload("res://character reference/!$farmer_plowing_32x32.png")
	
	var dirs = ["attack_down", "attack_left", "attack_right", "attack_up"]
	for i in range(dirs.size()):
		var anim_name = dirs[i]
		if not frames.has_animation(anim_name):
			frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, 10.0)
		frames.set_animation_loop(anim_name, false)
		
		# Clear existing frames just in case
		frames.clear(anim_name)
		
		for col in range(6):
			var region = Rect2(col * 32, i * 64, 32, 64)
			var atlas = AtlasTexture.new()
			atlas.atlas = img
			atlas.region = region
			frames.add_frame(anim_name, atlas)

	ResourceSaver.save(frames, "res://assets/hunter_frames.tres")
	print("Hunter frames updated successfully with attack animations.")
	quit()

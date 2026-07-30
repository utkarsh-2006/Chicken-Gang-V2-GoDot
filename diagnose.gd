extends SceneTree

func _init():
	var file = FileAccess.open("res://diagnosis_report.txt", FileAccess.WRITE)
	if not file:
		print("Failed to open file for diagnosis.")
		quit()
		return

	# 1. Animations
	var frames = load("res://assets/hunter_frames.tres") as SpriteFrames
	if frames:
		for dir in ["attack_down", "attack_left", "attack_right", "attack_up"]:
			var exists = frames.has_animation(dir)
			file.store_line(dir + " exists: " + str(exists))
			if exists:
				file.store_line("  frames count: " + str(frames.get_frame_count(dir)))
				var tex = frames.get_frame_texture(dir, 0)
				if tex and tex is AtlasTexture:
					var path = tex.atlas.resource_path
					file.store_line("  texture path: " + path)
					file.store_line("  texture region: " + str(tex.region))

	# 2. Chicken take_hit standalone test
	var c = preload("res://scenes/entities/chicken/Chicken.tscn").instantiate()
	get_root().add_child(c)
	
	file.store_line("Chicken initial state: " + str(c.current_state))
	c.take_hit(1.5, 2, Vector2(100, 0))
	file.store_line("Chicken state after take_hit: " + str(c.current_state))
	file.store_line("Chicken stun_timer: " + str(c.stun_timer))
	file.store_line("Chicken velocity (knockback): " + str(c.velocity))
	
	file.close()
	quit()

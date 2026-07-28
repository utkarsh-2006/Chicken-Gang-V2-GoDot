extends SceneTree

func _init():
	var inputs = {
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"dash": [KEY_SPACE]
	}

	for action in inputs:
		if not ProjectSettings.has_setting("input/" + action):
			var events = []
			for keycode in inputs[action]:
				var event = InputEventKey.new()
				event.physical_keycode = keycode
				events.append(event)
			
			var info = {
				"deadzone": 0.5,
				"events": events
			}
			ProjectSettings.set_setting("input/" + action, info)

	# Set rendering for pixel art
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0) # 0 = Nearest

	var err = ProjectSettings.save()
	if err == OK:
		print("ProjectSettings successfully updated.")
	else:
		print("Failed to save ProjectSettings.")
	
	quit()

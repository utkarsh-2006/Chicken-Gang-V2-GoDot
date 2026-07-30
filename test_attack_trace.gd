extends Node2D

func _ready():
	var h = preload("res://scenes/entities/hunter/Hunter.tscn").instantiate()
	var c = preload("res://scenes/entities/chicken/Chicken.tscn").instantiate()
	add_child(h)
	add_child(c)
	h.global_position = Vector2(0,0)
	c.global_position = Vector2(10,0)
	
	h.current_target = c
	h.current_state = 1 # CHASE
	
	var file = FileAccess.open("res://attack_trace.txt", FileAccess.WRITE)
	
	for i in range(15):
		h._physics_process(0.016)
		file.store_line("Frame " + str(i) + " state: " + str(h.current_state) + " anim: " + str(h.anim.animation) + " anim_frame: " + str(h.anim.frame))
		h.anim.frame_progress += h.anim.sprite_frames.get_animation_speed(h.anim.animation) * 0.016
		if h.anim.frame_progress >= 1.0:
			h.anim.frame += 1
			h.anim.frame_progress = 0.0
			h._on_anim_frame_changed()
			if h.anim.frame >= h.anim.sprite_frames.get_frame_count(h.anim.animation):
				h._on_anim_finished()
	
	file.close()
	get_tree().quit()

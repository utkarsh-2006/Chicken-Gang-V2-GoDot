extends SceneTree
func _init():
	var h = preload("res://scenes/entities/hunter/Hunter.tscn").instantiate()
	# Call _ready to set up connections (or wait, _ready is not called in SceneTree automatically)
	h._ready()
	var anim = h.get_node("AnimatedSprite2D")
	print("frame_changed connections:")
	for c in anim.get_signal_connection_list("frame_changed"):
		print(c)
	print("animation_finished connections:")
	for c in anim.get_signal_connection_list("animation_finished"):
		print(c)
	quit()

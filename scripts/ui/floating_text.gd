extends Node2D

@onready var label: Label = $Label

func setup(text: String, start_pos: Vector2, color: Color) -> void:
	global_position = start_pos
	
	# We need to wait for ready if called before added to tree, 
	# but setting it dynamically is fine if instantiated correctly
	if not is_node_ready():
		await ready
		
	label.text = text
	label.modulate = color
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "global_position:y", global_position.y - 40.0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	tween.chain().tween_callback(queue_free)

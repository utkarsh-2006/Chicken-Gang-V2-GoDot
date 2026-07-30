extends Node2D

func _ready():
	var file = FileAccess.open("res://diagnosis_report_2.txt", FileAccess.WRITE)
	
	var c = preload("res://scenes/entities/chicken/Chicken.tscn").instantiate()
	add_child(c)
	
	file.store_line("Chicken initial state: " + str(c.current_state))
	
	# Try taking hit
	c.take_hit(1.5, 2, Vector2(100, 0))
	
	file.store_line("Chicken state after take_hit: " + str(c.current_state))
	file.store_line("Chicken stun_timer: " + str(c.stun_timer))
	file.store_line("Chicken velocity: " + str(c.velocity))
	
	file.close()
	get_tree().quit()

extends SceneTree
func _init():
	var img = Image.new()
	var err = img.load("res://character reference/!$farmer_plowing_32x32.png")
	if err == OK:
		print("FARMER_PLOWING_SIZE: ", img.get_width(), "x", img.get_height())
	else:
		print("FAILED TO LOAD IMAGE: ", err)
	quit()

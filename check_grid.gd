extends SceneTree
func _init():
	var img = Image.new()
	img.load("res://character reference/!$farmer_plowing_32x32.png")
	var w = img.get_width()
	var h = img.get_height()
	print("Size: ", w, "x", h)
	
	# Check 48x64 grid
	print("Checking 48x64 Grid (4 cols, 4 rows):")
	for r in range(4):
		for c in range(4):
			var has_pixel = false
			for y in range(r*64, (r+1)*64):
				for x in range(c*48, (c+1)*48):
					if img.get_pixel(x, y).a > 0.1:
						has_pixel = true
						break
				if has_pixel: break
			print("Row ", r, " Col ", c, " has_pixel: ", has_pixel)
			
	# Check 32x64 grid
	print("Checking 32x64 Grid (6 cols, 4 rows):")
	for r in range(4):
		for c in range(6):
			var has_pixel = false
			for y in range(r*64, (r+1)*64):
				for x in range(c*32, (c+1)*32):
					if img.get_pixel(x, y).a > 0.1:
						has_pixel = true
						break
				if has_pixel: break
			print("Row ", r, " Col ", c, " has_pixel: ", has_pixel)
	
	# Check 32x32 grid
	print("Checking 32x32 Grid (6 cols, 8 rows):")
	for r in range(8):
		for c in range(6):
			var has_pixel = false
			for y in range(r*32, (r+1)*32):
				for x in range(c*32, (c+1)*32):
					if img.get_pixel(x, y).a > 0.1:
						has_pixel = true
						break
				if has_pixel: break
			print("Row ", r, " Col ", c, " has_pixel: ", has_pixel)
			
	quit()

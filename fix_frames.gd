extends SceneTree

func _init():
	var frames = ResourceLoader.load("res://assets/hunter_frames.tres") as SpriteFrames
	var tex = ResourceLoader.load("res://character reference/!$farmer_plowing_32x32.png") as Texture2D
	
	for dir in ["down", "left", "right", "up"]:
		var anim = "attack_" + dir
		frames.clear(anim)
		
		# Align frames so the character's feet rest exactly at the bottom of the 64x64 region.
		# The walking sprite (32x64) has feet at the very bottom (local Y=64).
		# In the plowing sprite, Down feet are at local Y=64.
		# But Left, Right, and Up feet are drawn at local Y=52.
		# To make their feet sit at local Y=64 (so the origin perfectly matches the walking sprite),
		# we shift the crop region UP by 12 pixels (64 - 52 = 12).
		
		var y = 0
		if dir == "down": y = 0           # Row 0 starts at 0. Feet at 64. Region: 0 to 64.
		elif dir == "left": y = 64 - 12   # Row 1 starts at 64. Feet at 116. Region: 52 to 116.
		elif dir == "right": y = 128 - 12 # Row 2 starts at 128. Feet at 180. Region: 116 to 180.
		elif dir == "up": y = 192 - 12    # Row 3 starts at 192. Feet at 244. Region: 180 to 244.
		
		for col in range(3):
			var atlas = AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(col * 64, y, 64, 64)
			frames.add_frame(anim, atlas)
			
		frames.set_animation_loop(anim, false)
		frames.set_animation_speed(anim, 10.0)
	
	ResourceSaver.save(frames, "res://assets/hunter_frames.tres")
	print("hunter_frames.tres saved successfully with vertically aligned 64x64 regions.")
	quit(0)

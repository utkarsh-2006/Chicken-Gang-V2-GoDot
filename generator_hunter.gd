extends Node2D

func _ready():
    var file_path = "res://assets/hunter_frames.tres"
    print("STARTING HUNTER GENERATION...")
    var frames = SpriteFrames.new()
    var img = Image.new()
    var err_img = img.load("res://assets/farmer.png")
    if err_img != OK:
        print("ERROR: Texture not found")
        get_tree().quit()
        return
    var texture = ImageTexture.create_from_image(img)
        
    var frame_w = 32
    var frame_h = 64
    
    var create_frame = func(col, row):
        var atlas = AtlasTexture.new()
        atlas.atlas = texture
        atlas.region = Rect2(col * frame_w, row * frame_h, frame_w, frame_h)
        return atlas
        
    # Row 0=Down, Row 1=Left, Row 2=Right, Row 3=Up
    var directions = ["down", "left", "right", "up"]
    
    for row in range(4):
        var dir = directions[row]
        
        # Idle (Column 1)
        var idle_name = "idle_" + dir
        frames.add_animation(idle_name)
        frames.set_animation_loop(idle_name, true)
        frames.set_animation_speed(idle_name, 5.0)
        frames.add_frame(idle_name, create_frame.call(1, row))
        
        # Walk (Column 0 -> 1 -> 2 -> 1)
        var walk_name = "walk_" + dir
        frames.add_animation(walk_name)
        frames.set_animation_loop(walk_name, true)
        frames.set_animation_speed(walk_name, 6.0)
        frames.add_frame(walk_name, create_frame.call(0, row))
        frames.add_frame(walk_name, create_frame.call(1, row))
        frames.add_frame(walk_name, create_frame.call(2, row))
        frames.add_frame(walk_name, create_frame.call(1, row))

    var err = ResourceSaver.save(frames, file_path)
    if err == OK:
        print("SpriteFrames successfully saved to " + file_path)
    else:
        print("ERROR saving file: ", err)
        
    get_tree().quit()

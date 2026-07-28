extends Node2D

func _ready():
    var file_path = "res://assets/worm_frames.tres"
    print("STARTING WORM GENERATION...")
    var frames = SpriteFrames.new()
    var img = Image.new()
    var err_img = img.load("res://assets/worm.png")
    if err_img != OK:
        print("ERROR: Texture not found")
        get_tree().quit()
        return
    var texture = ImageTexture.create_from_image(img)
        
    var frame_w = 30
    var frame_h = 34
    
    var create_frame = func(col, row):
        var atlas = AtlasTexture.new()
        atlas.atlas = texture
        atlas.region = Rect2(col * frame_w, row * frame_h, frame_w, frame_h)
        return atlas
        
    # We will just use the first row (Down direction) for the worm's idle wiggle
    var idle_name = "idle"
    frames.add_animation(idle_name)
    frames.set_animation_loop(idle_name, true)
    frames.set_animation_speed(idle_name, 4.0)
    
    # 3 columns in the row
    frames.add_frame(idle_name, create_frame.call(0, 0))
    frames.add_frame(idle_name, create_frame.call(1, 0))
    frames.add_frame(idle_name, create_frame.call(2, 0))
    frames.add_frame(idle_name, create_frame.call(1, 0))

    var err = ResourceSaver.save(frames, file_path)
    if err == OK:
        print("Worm SpriteFrames successfully saved to " + file_path)
    else:
        print("ERROR saving file: ", err)
        
    get_tree().quit()

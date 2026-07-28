extends SceneTree

func _init():
    var frames = SpriteFrames.new()
    var texture = load("res://assets/chicken.png")
    
    # 3 columns, 4 rows. Frame size 32x32.
    var frame_w = 32
    var frame_h = 32
    
    # Helper to create AtlasTexture
    var create_frame = func(col, row):
        var atlas = AtlasTexture.new()
        atlas.atlas = texture
        atlas.region = Rect2(col * frame_w, row * frame_h, frame_w, frame_h)
        return atlas
        
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
        frames.set_animation_speed(walk_name, 8.0)
        frames.add_frame(walk_name, create_frame.call(0, row))
        frames.add_frame(walk_name, create_frame.call(1, row))
        frames.add_frame(walk_name, create_frame.call(2, row))
        frames.add_frame(walk_name, create_frame.call(1, row))
        
    # Hidden animation
    frames.add_animation("hidden")
    frames.set_animation_loop("hidden", true)
    frames.set_animation_speed("hidden", 1.0)
    var hidden_tex = AtlasTexture.new()
    hidden_tex.atlas = texture
    hidden_tex.region = Rect2(0, 0, 0, 0) # empty
    frames.add_frame("hidden", hidden_tex)
    
    # Stunned animation (reuse idle_down)
    frames.add_animation("stunned")
    frames.set_animation_loop("stunned", true)
    frames.set_animation_speed("stunned", 5.0)
    frames.add_frame("stunned", create_frame.call(1, 0)) # Down idle frame

    # Save
    ResourceSaver.save(frames, "res://assets/chicken_frames.tres")
    print("SpriteFrames generated at res://assets/chicken_frames.tres")
    quit()

extends SceneTree

func _init():
    var timer = create_timer(2.0)
    timer.timeout.connect(_on_timeout)
    var scene = load("res://main.tscn")
    if scene:
        var instance = scene.instantiate()
        if instance:
            print("SUCCESS: main.tscn instantiated!")
            root.add_child(instance)
        else:
            print("ERROR: Failed to instantiate main.tscn")
    else:
        print("ERROR: Failed to load main.tscn")

func _on_timeout():
    quit()

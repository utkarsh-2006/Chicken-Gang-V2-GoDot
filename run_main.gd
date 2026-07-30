extends SceneTree

func _init():
    var scene = load("res://main.tscn")
    if scene:
        var instance = scene.instantiate()
        root.add_child(instance)
        # Give it a couple frames to initialize and dump
        await create_timer(0.2).timeout
    quit()

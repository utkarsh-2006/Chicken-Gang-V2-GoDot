extends SceneTree

func _init():
    var timer = create_timer(1.0)
    timer.timeout.connect(_on_timeout)
    var scene = load("res://assets/maps/ChickenGangMap.tmx")
    if scene:
        var instance = scene.instantiate()
        var tb = _find_node_by_name(instance, "worm spawn zones")
        var f = FileAccess.open("res://wz_dump2.txt", FileAccess.WRITE)
        if tb:
            _print_node(tb, 0, f)
        else:
            f.store_line("Node 'worm spawn zones' not found.")
        f.flush()
        f.close()
    else:
        var f = FileAccess.open("res://wz_dump2.txt", FileAccess.WRITE)
        f.store_line("Failed to load map")
        f.close()

func _on_timeout():
    quit()

func _find_node_by_name(node: Node, target_name: String) -> Node:
    if node.name == target_name:
        return node
    for child in node.get_children():
        var found = _find_node_by_name(child, target_name)
        if found:
            return found
    return null

func _print_node(node: Node, depth: int, f: FileAccess):
    var indent = "  ".repeat(depth)
    var info = node.name + " (" + node.get_class() + ")"
    if node is Node2D:
        info += " | pos: " + str(node.position)
    if node is Area2D or node is StaticBody2D:
        info += " | collision_layer: " + str(node.collision_layer)
    if node is CollisionShape2D:
        var shape = node.shape
        if shape is RectangleShape2D:
            info += " | shape: RectangleShape2D, size: " + str(shape.size)
    f.store_line(indent + info)
    for child in node.get_children():
        _print_node(child, depth + 1, f)

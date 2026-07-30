extends SceneTree

func _init():
    var scene = load("res://assets/maps/ChickenGangMap.tmx")
    if scene:
        var instance = scene.instantiate()
        var tb = _find_node_by_name(instance, "tall_buildings")
        var f = FileAccess.open("res://tb_dump.txt", FileAccess.WRITE)
        if tb:
            _print_node(tb, 0, f)
        else:
            f.store_line("Node 'tall_buildings' not found. YATI may not have imported it correctly, or the user hasn't saved it yet.")
        f.close()
    else:
        var f = FileAccess.open("res://tb_dump.txt", FileAccess.WRITE)
        f.store_line("Failed to load map")
        f.close()
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
        info += " | z: " + str(node.z_index)
        if node.y_sort_enabled:
            info += " | ysort: true"
    if node is Sprite2D:
        info += " | offset: " + str(node.offset)
        info += " | scale: " + str(node.scale)
        info += " | rect: " + str(node.region_rect)
    f.store_line(indent + info)
    for child in node.get_children():
        _print_node(child, depth + 1, f)

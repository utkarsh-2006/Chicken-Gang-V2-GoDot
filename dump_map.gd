extends SceneTree
func _init():
	var scene = preload("res://assets/maps/ChickenGangMap.tmx").instantiate()
	var f = FileAccess.open("res://dump.txt", FileAccess.WRITE)
	_dump(scene, 0, f)
	f.close()
	quit()

func _dump(node, depth, f):
	var indent = ""
	for i in range(depth): indent += "  "
	f.store_line(indent + node.name + " (" + node.get_class() + ")")
	if node is StaticBody2D:
		f.store_line(indent + "  => StaticBody2D, layer: " + str(node.collision_layer))
	if node is TileMapLayer:
		f.store_line(indent + "  => TileMapLayer, collision_layer: " + str(node.collision_layer))
	for child in node.get_children():
		_dump(child, depth + 1, f)

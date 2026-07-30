extends SceneTree

func _init():
	var c = preload('res://scenes/entities/chicken/Chicken.tscn').instantiate()
	var cs = c.get_node('CollisionShape2D').shape
	if cs is CircleShape2D: print('Chicken: Circle, r=', cs.radius)
	elif cs is RectangleShape2D: print('Chicken: Rect, size=', cs.size)
	var cp = c.get_node('CollisionShape2D').position
	print('Chicken local pos: ', cp)

	var h = preload('res://scenes/entities/hunter/Hunter.tscn').instantiate()
	var hs = h.get_node('CollisionShape2D').shape
	if hs is CircleShape2D: print('Hunter: Circle, r=', hs.radius)
	elif hs is RectangleShape2D: print('Hunter: Rect, size=', hs.size)
	var hp = h.get_node('CollisionShape2D').position
	print('Hunter local pos: ', hp)
	print('Hunter NavAgent radius: ', h.get_node('NavigationAgent2D').radius)

	var lm = preload('res://scripts/managers/level_manager.gd').new()
	print('LevelManager Navigation Polygon agent radius: ', lm.agent_radius if "agent_radius" in lm else "UNKNOWN")

	quit()

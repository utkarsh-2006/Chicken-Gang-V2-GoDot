@tool
extends TileMapLayer

func _ready() -> void:
	if Engine.is_editor_hint():
		build_map()

func build_map() -> void:
	if get_used_rect().size.x > 0:
		return
		
	for y in range(40):
		for x in range(60):
			var atlas = Vector2i(0, 0) # grass
			
			if (y == 15 or y == 16) and x >= 10 and x < 50:
				atlas = Vector2i(1, 0)
			elif (x == 30 or x == 31) and y >= 5 and y < 35:
				atlas = Vector2i(1, 0)
			
			if (x-14)*(x-14) + (y-29)*(y-29) < 20:
				atlas = Vector2i(2, 0)
				
			if x >= 40 and x <= 51 and y >= 8 and y <= 13:
				if y == 8 or y == 13 or x == 40 or x == 51:
					atlas = Vector2i(1, 1) # wood
					
			if x >= 10 and x < 50 and (x % 4 != 0):
				if y == 2 or y == 37: atlas = Vector2i(1, 1)
			if y >= 2 and y < 38 and (y % 4 != 0):
				if x == 5 or x == 55: atlas = Vector2i(1, 1)
				
			if x >= 40 and x < 48 and y >= 20 and y < 28:
				atlas = Vector2i(0, 1) # corn
				
			if (x == 28 or x == 33) and (y == 15 or y == 16):
				atlas = Vector2i(2, 1) # stone
				
			set_cell(Vector2i(x, y), 0, atlas)

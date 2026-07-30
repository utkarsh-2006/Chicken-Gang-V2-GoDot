extends Node2D
class_name LevelManager

signal level_ready(spawn_points: Array)
signal worm_spawns_ready(worm_spawns: Array)
signal animal_spawns_ready(animal_zones: Array)

@export var world_scene: PackedScene
var hiding_spot_scene = preload("res://scenes/environment/HidingSpot.tscn")

func _ready() -> void:
	if world_scene:
		var world_instance = world_scene.instantiate()
		add_child(world_instance)
		
		var tall_b = _find_node_by_name(world_instance, "tall_buildings")
		if tall_b: tall_b.y_sort_enabled = true		
		call_deferred("_run_adapters", world_instance)
	else:
		push_error("LevelManager: No world_scene assigned!")

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


func _run_adapters(world_instance: Node2D) -> void:
	var spawn_points: Array = []
	
	# --- 1. SpawnAdapter ---
	var player_spawns_node = world_instance.get_node_or_null("player spawns")
	if player_spawns_node:
		var player_idx = 0
		for child in player_spawns_node.get_children():
			if child is Marker2D:
				var sp = SpawnPoint.new()
				sp.global_position = child.global_position
				sp.spawn_type = SpawnPoint.SpawnType.PLAYER_1 if player_idx % 2 == 0 else SpawnPoint.SpawnType.PLAYER_2
				spawn_points.append(sp)
				player_idx += 1
				
	var hunter_spawns_node = world_instance.get_node_or_null("hunter spwans")
	if hunter_spawns_node:
		for child in hunter_spawns_node.get_children():
			if child is Marker2D:
				var sp = SpawnPoint.new()
				sp.global_position = child.global_position
				sp.spawn_type = SpawnPoint.SpawnType.HUNTER
				spawn_points.append(sp)

	# --- 2. HidingAdapter ---
	var hiding_zones_node = world_instance.get_node_or_null("hiding zones")
	if hiding_zones_node:
		for child in hiding_zones_node.get_children():
			if child is StaticBody2D:
				var col_shape = null
				for c in child.get_children():
					if c is CollisionShape2D and c.shape is RectangleShape2D:
						col_shape = c
						break
				
				if col_shape:
					var hs = hiding_spot_scene.instantiate()
					hs.global_position = col_shape.global_position
					
					var rect_size = col_shape.shape.size
					var new_shape = RectangleShape2D.new()
					new_shape.size = rect_size
					
					var hs_collision = hs.get_node_or_null("CollisionShape2D")
					if hs_collision:
						hs_collision.shape = new_shape
						
					add_child(hs)
					
				# Remove the solid collision behavior for the hiding zone
				child.queue_free()

	# --- 3. TractorAdapter ---
	var tractor_path_node = world_instance.get_node_or_null("tractor path")

	# --- 4. Worm Zone Adapter ---
	var worm_zones: Array = []
	var worm_spawns_node = world_instance.get_node_or_null("worm spawn zones")
	if worm_spawns_node:
		for child in worm_spawns_node.get_children():
			if child is StaticBody2D:
				var col_shape = null
				for c in child.get_children():
					if c is CollisionShape2D and c.shape is RectangleShape2D:
						col_shape = c
						break
				
				if col_shape:
					var rect_size = col_shape.shape.size
					# YATI offsets the position, so the collision shape is centered at global_position
					var rect_pos = col_shape.global_position - rect_size / 2.0
					worm_zones.append(Rect2(rect_pos, rect_size))
					col_shape.disabled = true
					
				# Completely remove the solid collision behavior so it doesn't block the game
				child.collision_layer = 0
				child.collision_mask = 0
				child.queue_free()

	# --- 5. Animal Zone Adapter ---
	var animal_zones: Array = []
	var animal_spawns_node = world_instance.get_node_or_null("animal spawn zones")
	if animal_spawns_node:
		for child in animal_spawns_node.get_children():
			if child is StaticBody2D:
				var col_shape = null
				for c in child.get_children():
					if c is CollisionShape2D and c.shape is RectangleShape2D:
						col_shape = c
						break
				
				if col_shape:
					var rect_size = col_shape.shape.size
					var rect_pos = col_shape.global_position - rect_size / 2.0
					animal_zones.append(Rect2(rect_pos, rect_size))
					col_shape.disabled = true
					
				child.collision_layer = 0
				child.collision_mask = 0
				child.queue_free()

	# --- 6. Vision Blocker Adapter ---
	var collision_node = world_instance.get_node_or_null("collision")
	var tall_layers = []
	for child in world_instance.get_children():
		if child is TileMapLayer:
			var ln = child.name.to_lower()
			if ln in ["buildings", "tall_buildings", "trees up", "trees down"]:
				tall_layers.append(child)
				
	if collision_node:
		for child in collision_node.get_children():
			if child is StaticBody2D:
				var is_tall = false
				
				# Get center of shape
				var center = child.global_position
				var shape = child.get_child(0)
				if shape and shape is CollisionShape2D and shape.shape is RectangleShape2D:
					center += shape.position
					
				for tl in tall_layers:
					var map_pos = tl.local_to_map(tl.to_local(center))
					if tl.get_cell_source_id(map_pos) != -1:
						is_tall = true
						break
				
				if is_tall:
					# Tall obstacles (Houses, Barns, Tall Trees) block vision and movement (Layer 1)
					child.collision_layer = 1
				else:
					# Low obstacles (Fences, Water) block movement only (Layer 2)
					child.collision_layer = 2

	if tractor_path_node:
		var path2d = Path2D.new()
		path2d.name = "TractorPath"
		var curve = Curve2D.new()
		
		for child in tractor_path_node.get_children():
			if child is StaticBody2D:
				for c in child.get_children():
					if c is CollisionPolygon2D:
						var poly = c.polygon
						for pt in poly:
							curve.add_point(c.to_global(pt))
						if poly.size() > 0:
							curve.add_point(c.to_global(poly[0]))
				
				# Remove the collision behavior for the tractor path
				child.queue_free()
		
		path2d.curve = curve
		add_child(path2d)

	# --- 4. Camera Bounds Adapter ---
	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)
	
	for child in world_instance.get_children():
		if child is TileMapLayer:
			var rect = child.get_used_rect()
			if rect.has_area():
				var tile_size = child.tile_set.tile_size if child.tile_set else Vector2i(32, 32)
				var local_min = Vector2(rect.position.x * tile_size.x, rect.position.y * tile_size.y)
				var local_max = Vector2(rect.end.x * tile_size.x, rect.end.y * tile_size.y)
				
				min_pos.x = min(min_pos.x, local_min.x)
				min_pos.y = min(min_pos.y, local_min.y)
				max_pos.x = max(max_pos.x, local_max.x)
				max_pos.y = max(max_pos.y, local_max.y)
				
	if min_pos.x != INF:
		var camera = get_node_or_null("../DynamicCamera")
		if camera and camera is Camera2D:
			camera.limit_left = int(min_pos.x)
			camera.limit_top = int(min_pos.y)
			camera.limit_right = int(max_pos.x)
			camera.limit_bottom = int(max_pos.y)
			
		_bake_navigation(min_pos, max_pos)

	level_ready.emit(spawn_points)
	if not worm_zones.is_empty():
		worm_spawns_ready.emit(worm_zones)
	if not animal_zones.is_empty():
		animal_spawns_ready.emit(animal_zones)

func _bake_navigation(min_pos: Vector2, max_pos: Vector2) -> void:
	var nav_poly = NavigationPolygon.new()
	nav_poly.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	nav_poly.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_ROOT_NODE_CHILDREN
	nav_poly.agent_radius = 10.0 # From Hunter.tscn CollisionShape2D radius
	
	# Safety bounds in case empty
	if min_pos.x == INF:
		min_pos = Vector2(0, 0)
		max_pos = Vector2(2240, 2080)
		
	# Expand bounds slightly to ensure edge navigation
	var outline = PackedVector2Array([
		Vector2(min_pos.x - 50, min_pos.y - 50),
		Vector2(max_pos.x + 50, min_pos.y - 50),
		Vector2(max_pos.x + 50, max_pos.y + 50),
		Vector2(min_pos.x - 50, max_pos.y + 50)
	])
	nav_poly.add_outline(outline)
	
	var nav_region = NavigationRegion2D.new()
	nav_region.name = "RuntimeNavRegion"
	nav_region.navigation_polygon = nav_poly
	add_child(nav_region)
	
	# Synchronous bake
	var source_data = NavigationMeshSourceGeometryData2D.new()
	NavigationServer2D.parse_source_geometry_data(nav_poly, source_data, self)
	NavigationServer2D.bake_from_source_geometry_data(nav_poly, source_data)
	
	print("LevelManager: Navigation baked with agent_radius ", nav_poly.agent_radius, ", Map Bounds: ", min_pos, " to ", max_pos)
	print("LevelManager: Baked polygons count: ", nav_poly.get_polygon_count())


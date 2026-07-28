extends Node2D
class_name LevelManager

signal level_ready(spawn_points: Array)
signal worm_spawns_ready(worm_spawns: Array)

@export var world_scene: PackedScene
var hiding_spot_scene = preload("res://scenes/environment/HidingSpot.tscn")

func _ready() -> void:
	if world_scene:
		var world_instance = world_scene.instantiate()
		add_child(world_instance)
		call_deferred("_run_adapters", world_instance)
	else:
		push_error("LevelManager: No world_scene assigned!")

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

	# --- 4. WormAdapter ---
	var worm_spawns: Array = []
	var worm_spawns_node = world_instance.get_node_or_null("worm spawns")
	if worm_spawns_node:
		for child in worm_spawns_node.get_children():
			if child is Marker2D or child is Node2D:
				var w_data = {
					"position": child.global_position,
					"type": "common",
					"enabled": true,
					"respawn_time": -1.0 # fallback to default
				}
				# If Tiled custom properties are converted to meta
				if child.has_meta("type"): w_data["type"] = child.get_meta("type")
				if child.has_meta("enabled"): w_data["enabled"] = child.get_meta("enabled")
				if child.has_meta("respawn_time"): w_data["respawn_time"] = float(child.get_meta("respawn_time"))
				
				if w_data["enabled"]:
					worm_spawns.append(w_data)

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

	level_ready.emit(spawn_points)
	worm_spawns_ready.emit(worm_spawns)

extends Node2D
class_name GameManager

@export var chicken_scene: PackedScene = preload("res://scenes/entities/chicken/Chicken.tscn")
@export var hunter_scene: PackedScene = preload("res://scenes/entities/hunter/Hunter.tscn")
@export var worm_scene: PackedScene = preload("res://scenes/entities/collectible/Worm.tscn")

var dynamic_camera: Camera2D
var worm_manager: Node

func _ready() -> void:
	# Expects siblings "Level" and "DynamicCamera" in main.tscn
	var level = get_node_or_null("../Level")
	dynamic_camera = get_node_or_null("../DynamicCamera")
	
	if level and level is LevelManager:
		level.level_ready.connect(_on_level_ready)
		if level.has_signal("worm_spawns_ready"):
			level.worm_spawns_ready.connect(_on_worm_spawns_ready)
		
	# Setup worm manager
	worm_manager = Node.new()
	worm_manager.name = "WormManager"
	var wm_script = preload("res://scripts/managers/worm_manager.gd")
	worm_manager.set_script(wm_script)
	worm_manager.worm_scene = worm_scene
	add_child(worm_manager)

func _on_level_ready(spawn_points: Array) -> void:
	var players = []
	for sp in spawn_points:
		match sp.spawn_type:
			SpawnPoint.SpawnType.PLAYER_1:
				var p1 = chicken_scene.instantiate()
				p1.global_position = sp.global_position
				p1.player_id = "p1"
				add_child(p1)
				players.append(p1)
			SpawnPoint.SpawnType.PLAYER_2:
				var p2 = chicken_scene.instantiate()
				p2.global_position = sp.global_position
				p2.player_id = "p2"
				p2.modulate = Color(0.2, 0.6, 1.0)
				add_child(p2)
				players.append(p2)
			SpawnPoint.SpawnType.HUNTER:
				var hunter = hunter_scene.instantiate()
				hunter.global_position = sp.global_position
				add_child(hunter)
			SpawnPoint.SpawnType.WORM_ZONE:
				pass
	
	if dynamic_camera and dynamic_camera.has_method("add_target"):
		for p in players:
			dynamic_camera.add_target(p)

func _on_worm_spawns_ready(worm_spawns: Array) -> void:
	if worm_manager and worm_manager.has_method("initialize_map_spawns"):
		worm_manager.initialize_map_spawns(worm_spawns)

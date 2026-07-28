extends Node2D

func _ready():
    var file = FileAccess.open("res://test_output.txt", FileAccess.WRITE)
    file.store_line("=== TEST 1 & 2 & 3 & 4 & 5 ===")
    
    var main_scene = load("res://main.tscn")
    if not main_scene:
        file.store_line("FAIL: Could not load main.tscn")
        get_tree().quit()
        return
        
    var main = main_scene.instantiate()
    add_child(main)
    
    # Wait for deferred level ready
    await get_tree().process_frame
    await get_tree().process_frame
    await get_tree().process_frame
    
    # Check LevelManager
    var level = main.get_node_or_null("Level")
    if not level:
        file.store_line("FAIL: Level node missing")
        get_tree().quit()
        return
        
    var world = null
    for child in level.get_children():
        if child.name == "ChickenGangMap":
            world = child
            break
            
    if not world:
        file.store_line("FAIL: ChickenGangMap not instantiated")
        get_tree().quit()
        return
        
    file.store_line("PASS: world_scene instantiated successfully")
    
    # Test 3: Print debug output
    var player_spawns = world.get_node_or_null("player spawns")
    var hunter_spawns = world.get_node_or_null("hunter spwans")
    var hiding_zones = world.get_node_or_null("hiding zones")
    var tractor_path = world.get_node_or_null("tractor path")
    var collision_node = world.get_node_or_null("collision")
    
    file.store_line("Player spawn count: " + str(player_spawns.get_child_count() if player_spawns else 0))
    file.store_line("Hunter spawn count: " + str(hunter_spawns.get_child_count() if hunter_spawns else 0))
    
    var hiding_spot_count = 0
    for child in level.get_children():
        if child.has_method("hide_player") or child.name.begins_with("HidingSpot"):
            hiding_spot_count += 1
    file.store_line("Hiding spot count (generated): " + str(hiding_spot_count))
    file.store_line("Hiding zone count (original): " + str(hiding_zones.get_child_count() if hiding_zones else 0))
    
    file.store_line("Tractor polygon count: " + str(tractor_path.get_child_count() if tractor_path else 0))
    file.store_line("Collision count: " + str(collision_node.get_child_count() if collision_node else 0))
    
    # Test 4: GameManager
    var gm = main.get_node_or_null("GameManager")
    var players = []
    var hunters = []
    for child in gm.get_children():
        if child.name.begins_with("Chicken"):
            players.append(child)
        elif child.name.begins_with("Hunter"):
            hunters.append(child)
            
    file.store_line("Players spawned in GM: " + str(players.size()))
    file.store_line("Hunters spawned in GM: " + str(hunters.size()))
    
    # Test 5: Spawn positions
    for p in players:
        file.store_line("Player pos: " + str(p.global_position))
        if p.global_position == Vector2.ZERO:
            file.store_line("FAIL: Player spawned at 0,0")
    for h in hunters:
        file.store_line("Hunter pos: " + str(h.global_position))
        if h.global_position == Vector2.ZERO:
            file.store_line("FAIL: Hunter spawned at 0,0")
            
    file.close()
    get_tree().quit()

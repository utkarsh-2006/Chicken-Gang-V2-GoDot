extends Node2D

func _ready():
    var file = FileAccess.open("res://test_output3.txt", FileAccess.WRITE)
    var main_scene = load("res://main.tscn")
    var main = main_scene.instantiate()
    add_child(main)
    
    await get_tree().process_frame
    await get_tree().process_frame
    await get_tree().process_frame
    
    var gm = main.get_node_or_null("GameManager")
    for child in gm.get_children():
        file.store_line("GM Child: " + child.name)
        
    var level = main.get_node_or_null("Level")
    for child in level.get_children():
        file.store_line("Level Child: " + child.name)
        
    file.close()
    get_tree().quit()

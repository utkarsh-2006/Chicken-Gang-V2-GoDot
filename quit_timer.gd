extends Node

func _ready():
    var timer = get_tree().create_timer(3.0)
    timer.timeout.connect(func(): get_tree().quit())

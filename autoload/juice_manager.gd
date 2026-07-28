extends Node

@export var floating_text_scene: PackedScene = preload("res://scenes/ui/FloatingText.tscn")

func _ready() -> void:
	SignalBus.spawn_floating_text.connect(_on_spawn_floating_text)
	SignalBus.spawn_particles.connect(_on_spawn_particles)

func _on_spawn_particles(global_pos: Vector2, color: Color) -> void:
	var particles = CPUParticles2D.new()
	particles.global_position = global_pos
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 12
	particles.lifetime = 0.5
	particles.spread = 180.0
	particles.gravity = Vector2(0, 0)
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 100.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = color
	
	get_tree().current_scene.add_child(particles)
	get_tree().create_timer(1.0).timeout.connect(particles.queue_free)

func _on_spawn_floating_text(text: String, global_pos: Vector2, color: Color) -> void:
	if not floating_text_scene: return
	
	var ft = floating_text_scene.instantiate()
	get_tree().current_scene.add_child(ft)
	
	if ft.has_method("setup"):
		ft.setup(text, global_pos, color)

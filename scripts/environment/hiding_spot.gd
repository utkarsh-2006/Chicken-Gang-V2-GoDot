extends Area2D
class_name HidingSpot

@export var hide_opacity: float = 0.5
@export var fade_duration: float = 0.2

func _ready() -> void:
	# Connect signals using Godot 4 syntax
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_hidden"):
		body.set_hidden(true)
		_fade_sprite(body, hide_opacity)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_hidden"):
		body.set_hidden(false)
		_fade_sprite(body, 1.0)

func _fade_sprite(node: Node2D, target_alpha: float) -> void:
	var sprite = node.get_node_or_null("AnimatedSprite2D")
	if sprite:
		# Use Godot 4's create_tween
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", target_alpha, fade_duration)

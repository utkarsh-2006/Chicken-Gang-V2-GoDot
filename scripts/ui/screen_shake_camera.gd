extends Camera2D

var shake_intensity: float = 0.0
var shake_timer: float = 0.0
var original_offset: Vector2

func _ready() -> void:
	original_offset = offset
	SignalBus.screen_shake_requested.connect(_on_shake_requested)

func _process(delta: float) -> void:
	if shake_timer > 0.0:
		shake_timer -= delta
		var random_offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_intensity
		offset = original_offset + random_offset
	else:
		offset = original_offset
		shake_intensity = 0.0

func _on_shake_requested(intensity: float, duration: float) -> void:
	shake_intensity = max(shake_intensity, intensity)
	shake_timer = max(shake_timer, duration)

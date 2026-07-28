extends Camera2D
class_name DynamicCamera

@export var min_zoom: float = 0.65
@export var max_zoom: float = 0.75
@export var margin: Vector2 = Vector2(250, 250)
@export var move_speed: float = 5.0
@export var zoom_speed: float = 3.0

var targets: Array[Node2D] = []

var shake_intensity: float = 0.0
var shake_timer: float = 0.0
var base_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	SignalBus.screen_shake_requested.connect(_on_shake_requested)

func add_target(target: Node2D) -> void:
	if not targets.has(target):
		targets.append(target)

func remove_target(target: Node2D) -> void:
	targets.erase(target)

func _process(delta: float) -> void:
	_handle_shake(delta)
	
	if targets.is_empty():
		return
		
	var valid_targets = []
	for t in targets:
		if is_instance_valid(t):
			valid_targets.append(t)
			
	if valid_targets.is_empty():
		return
		
	# Find local player (Player 1)
	var local_player = null
	for t in valid_targets:
		if "player_id" in t and t.player_id == "p1":
			local_player = t
			break
			
	if local_player == null:
		local_player = valid_targets[0] # Fallback
		
	# Smooth movement (Always center on local player)
	global_position = global_position.lerp(local_player.global_position, move_speed * delta)
	
	# Calculate required zoom based on all targets
	var min_pos = valid_targets[0].global_position
	var max_pos = valid_targets[0].global_position
	
	for t in valid_targets:
		min_pos.x = min(min_pos.x, t.global_position.x)
		min_pos.y = min(min_pos.y, t.global_position.y)
		max_pos.x = max(max_pos.x, t.global_position.x)
		max_pos.y = max(max_pos.y, t.global_position.y)
		
	var size = max_pos - min_pos
	var required_size = size + margin * 2.0
	
	var viewport_size = get_viewport_rect().size
	var zoom_x = viewport_size.x / max(required_size.x, 1.0)
	var zoom_y = viewport_size.y / max(required_size.y, 1.0)
	
	# Clamp tightly between min_zoom and max_zoom
	var target_zoom_val = clamp(min(zoom_x, zoom_y), min_zoom, max_zoom)
	var target_zoom = Vector2(target_zoom_val, target_zoom_val)
	
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)

func _handle_shake(delta: float) -> void:
	if shake_timer > 0.0:
		shake_timer -= delta
		var random_offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_intensity
		offset = base_offset + random_offset
	else:
		offset = base_offset
		shake_intensity = 0.0

func _on_shake_requested(intensity: float, duration: float) -> void:
	shake_intensity = max(shake_intensity, intensity)
	shake_timer = max(shake_timer, duration)

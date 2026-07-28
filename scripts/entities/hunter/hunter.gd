extends CharacterBody2D
class_name Hunter

enum State {
	PATROL,
	INVESTIGATE # Kept enum for future use, but only PATROL will run
}

@export_group("Movement")
@export var patrol_speed: float = 100.0

@export_group("AI Timings")
@export var patrol_wait_time: float = 1.5

@export_group("Vision")
@export var vision_radius: float = 220.0

@onready var vision_area: Area2D = $VisionArea
@onready var vision_shape: CollisionShape2D = $VisionArea/CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var current_state: State = State.PATROL
var state_timer: float = 0.0

var spawn_position: Vector2
var patrol_points: Array[Vector2] = []
var current_patrol_index: int = 0
var target_position: Vector2 = Vector2.ZERO

var last_direction: String = "down"
var show_debug: bool = true

func _ready() -> void:
	spawn_position = global_position
	
	if vision_shape and vision_shape.shape is CircleShape2D:
		var circle = vision_shape.shape as CircleShape2D
		circle.radius = vision_radius
		
	_pick_new_patrol_point()

func _physics_process(delta: float) -> void:
	_scan_for_targets()
	
	match current_state:
		State.PATROL:
			_update_patrol(delta)
			
	move_and_slide()
	_process_animations()
	
	if show_debug:
		queue_redraw()

func _scan_for_targets() -> void:
	var detected = false
	for body in vision_area.get_overlapping_bodies():
		if body is Chicken:
			if body.has_method("can_be_detected") and body.can_be_detected():
				detected = true
				break
				
	if detected:
		print("PLAYER DETECTED!")

func _pick_new_patrol_point() -> void:
	if patrol_points.size() > 0:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		target_position = patrol_points[current_patrol_index]
	else:
		# Fallback deterministic local patrol
		if target_position == spawn_position:
			target_position = spawn_position + Vector2(100, 0)
		else:
			target_position = spawn_position

func _move_towards(target: Vector2, speed: float) -> bool:
	var dist = global_position.distance_to(target)
	if dist < 10.0:
		velocity = Vector2.ZERO
		return true
		
	var dir = (target - global_position).normalized()
	velocity = dir * speed
	return false

func _update_patrol(delta: float) -> void:
	if _move_towards(target_position, patrol_speed):
		state_timer += delta
		if state_timer >= patrol_wait_time:
			_pick_new_patrol_point()
			state_timer = 0.0
	else:
		state_timer = 0.0

func _process_animations() -> void:
	if not anim: return
	
	if velocity == Vector2.ZERO:
		anim.play("idle_" + last_direction)
	else:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x < 0:
				last_direction = "left"
			else:
				last_direction = "right"
		else:
			if velocity.y < 0:
				last_direction = "up"
			else:
				last_direction = "down"
				
		anim.play("walk_" + last_direction)

func _draw() -> void:
	if not show_debug:
		return
		
	# Draw vision radius
	draw_arc(Vector2.ZERO, vision_radius, 0, TAU, 32, Color(1, 0, 0, 0.3), 2.0)
	
	# Draw line to target
	var local_target = to_local(target_position)
	draw_line(Vector2.ZERO, local_target, Color(0, 1, 0, 0.5), 2.0)
	
	# Draw state text
	var state_name = "PATROL" if current_state == State.PATROL else "OTHER"
	draw_string(ThemeDB.fallback_font, Vector2(-20, -40), state_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.YELLOW)

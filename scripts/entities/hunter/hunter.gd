extends CharacterBody2D
class_name Hunter

enum State {
	PATROL,
	CHASE,
	ATTACK,
	RETURN
}

@export_group("Movement")
@export var patrol_speed: float = 35.0
@export var chase_speed: float = 65.0

@export var patrol_wait_min: float = 2.0
@export var patrol_wait_max: float = 4.0
@export var patrol_radius: float = 200.0
@export var lost_target_grace: float = 1.5
@export var attack_range: float = 30.0
@export var attack_cooldown: float = 1.5
@export var preferred_attack_distance: float = 26.0
@export var chase_update_interval: float = 0.2

@export_group("Vision")
@export var vision_radius: float = 220.0
@export var show_debug: bool = false

@onready var vision_area: Area2D = $VisionArea
@onready var vision_shape: CollisionShape2D = $VisionArea/CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var current_state: State = State.PATROL
var state_timer: float = 0.0

var home_position: Vector2
var current_target: Chicken = null
var last_known_target_position: Vector2 = Vector2.ZERO
var lost_target_timer: float = 0.0
var chase_update_timer: float = 0.0

var last_direction: String = "down"
var target_position: Vector2 = Vector2.ZERO

var attack_cooldown_timer: float = 0.0
var has_hit_in_current_attack: bool = false

func _ready() -> void:
	home_position = global_position
	target_position = home_position
	
	if vision_shape and vision_shape.shape is CircleShape2D:
		var circle = vision_shape.shape as CircleShape2D
		circle.radius = vision_radius
		
	if anim:
		anim.frame_changed.connect(_on_anim_frame_changed)
		anim.animation_finished.connect(_on_anim_finished)
	
	if nav_agent:
		_wait_for_nav_sync()

func _wait_for_nav_sync() -> void:
	var map = get_world_2d().navigation_map
	if NavigationServer2D.map_get_iteration_id(map) > 0:
		_pick_new_patrol_point()
	else:
		await NavigationServer2D.map_changed
		_pick_new_patrol_point()

func _physics_process(delta: float) -> void:
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta

	if current_state != State.ATTACK:
		_scan_for_targets()
	
	match current_state:
		State.PATROL:
			_update_patrol(delta)
		State.CHASE:
			_update_chase(delta)
		State.ATTACK:
			velocity = Vector2.ZERO
		State.RETURN:
			_update_return(delta)
			
	move_and_slide()
	
	if current_state == State.CHASE and current_target != null:
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if col.get_collider() == current_target:
				velocity = Vector2.ZERO
				break
				
	_process_animations()
	
	if show_debug:
		queue_redraw()

func _scan_for_targets() -> void:
	var closest_chicken: Chicken = null
	var closest_dist: float = INF
	
	for body in vision_area.get_overlapping_bodies():
		if body is Chicken:
			# 1. Check if it's currently allowed to be detected (hiding)
			if body.has_method("can_be_detected") and not body.can_be_detected():
				continue
			
			# 2. Check line of sight (Environment mask = 1)
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(global_position, body.global_position, 1)
			query.exclude = [get_rid(), body.get_rid()]
			var result = space_state.intersect_ray(query)
			
			if result.is_empty():
				# Unobstructed!
				var dist = global_position.distance_squared_to(body.global_position)
				if dist < closest_dist:
					closest_dist = dist
					closest_chicken = body
					
	if closest_chicken != null:
		# Acquired a target or updated to a closer one
		if current_target != closest_chicken:
			current_state = State.CHASE
			current_target = closest_chicken
			lost_target_timer = 0.0
		# Update last known while visible
		last_known_target_position = current_target.global_position
		
	elif current_target != null:
		# We have a target but it's not visible this frame
		# If it's HIDDEN explicitly, break immediately
		if current_target.has_method("can_be_detected") and not current_target.can_be_detected():
			_lose_target()
			return
			
		# Otherwise, it's just normal LOS occlusion, start grace timer
		lost_target_timer += get_physics_process_delta_time()
		if lost_target_timer >= lost_target_grace:
			_lose_target()

func _lose_target() -> void:
	current_target = null
	current_state = State.RETURN
	if anim: anim.offset = Vector2(0, 0)
	if nav_agent:
		nav_agent.target_position = home_position
		target_position = home_position

func _pick_new_patrol_point() -> void:
	if not nav_agent:
		return
		
	var attempts = 5
	var map = get_world_2d().navigation_map
	
	for i in range(attempts):
		var angle = randf_range(0, TAU)
		var dist = randf_range(0, patrol_radius)
		var candidate = home_position + Vector2(cos(angle), sin(angle)) * dist
		
		# Get closest valid point on navmesh
		var valid_point = NavigationServer2D.map_get_closest_point(map, candidate)
		if valid_point.distance_to(candidate) < 50.0:
			nav_agent.target_position = valid_point
			target_position = valid_point
			return
			
	# Fallback
	nav_agent.target_position = home_position
	target_position = home_position

func _navigate_towards(speed: float) -> bool:
	if not nav_agent or nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return true
		
	var next_path_position = nav_agent.get_next_path_position()
	var dir = global_position.direction_to(next_path_position)
	
	# Apply steering/velocity
	velocity = dir * speed
	return false

func _update_patrol(delta: float) -> void:
	var arrived = _navigate_towards(patrol_speed)
	if arrived:
		state_timer += delta
		if state_timer >= randf_range(patrol_wait_min, patrol_wait_max):
			_pick_new_patrol_point()
			state_timer = 0.0
	else:
		state_timer = 0.0

func _update_chase(delta: float) -> void:
	if current_target:
		var dist = global_position.distance_to(current_target.global_position)
		
		if lost_target_timer == 0.0 and dist <= attack_range and attack_cooldown_timer <= 0.0:
			current_state = State.ATTACK
			velocity = Vector2.ZERO
			has_hit_in_current_attack = false
			
			var dir_to = current_target.global_position - global_position
			if abs(dir_to.x) > abs(dir_to.y):
				last_direction = "left" if dir_to.x < 0 else "right"
			else:
				last_direction = "up" if dir_to.y < 0 else "down"
				
			anim.offset = Vector2(0, -16)
			anim.play("attack_" + last_direction)
			return

		chase_update_timer -= delta
		
		if lost_target_timer == 0.0:
			if dist <= preferred_attack_distance:
				velocity = Vector2.ZERO
				return
				
			if nav_agent and chase_update_timer <= 0.0:
				nav_agent.target_position = current_target.global_position
				target_position = current_target.global_position
				chase_update_timer = chase_update_interval
		else:
			if nav_agent and chase_update_timer <= 0.0:
				nav_agent.target_position = last_known_target_position
				target_position = last_known_target_position
				chase_update_timer = chase_update_interval
				
		_navigate_towards(chase_speed)

func _update_return(delta: float) -> void:
	var arrived = _navigate_towards(patrol_speed)
	if arrived or global_position.distance_to(home_position) < 20.0:
		current_state = State.PATROL
		state_timer = 0.0
		_pick_new_patrol_point()

func _process_animations() -> void:
	if not anim: return
	if current_state == State.ATTACK: return
	
	anim.offset = Vector2(0, 0)
	
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
	
	if nav_agent and not nav_agent.is_navigation_finished():
		var current_agent_position = global_position
		var next_path_position = nav_agent.get_next_path_position()
		draw_line(Vector2.ZERO, to_local(next_path_position), Color.MAGENTA, 2.0)
		
	# Draw state text
	var state_name = State.keys()[current_state]
	draw_string(ThemeDB.fallback_font, Vector2(-20, -40), state_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.YELLOW)
	
	if current_state == State.CHASE:
		if current_target:
			draw_circle(to_local(current_target.global_position), 10.0, Color.RED)
		draw_circle(to_local(last_known_target_position), 8.0, Color.ORANGE)

func _on_anim_frame_changed() -> void:
	if current_state == State.ATTACK and not has_hit_in_current_attack:
		if anim.frame == 3:
			has_hit_in_current_attack = true
			if current_target and is_instance_valid(current_target):
				if current_target.has_method("can_be_detected") and not current_target.can_be_detected():
					_lose_target()
					return
				
				var dist = global_position.distance_to(current_target.global_position)
				if dist <= attack_range + 15.0:
					var knockback = (current_target.global_position - global_position).normalized() * 300.0
					current_target.take_hit(1.5, 2, knockback)

func _on_anim_finished() -> void:
	if current_state == State.ATTACK:
		anim.offset = Vector2(0, 0)
		attack_cooldown_timer = attack_cooldown
		if current_target and lost_target_timer == 0.0:
			current_state = State.CHASE
		else:
			_lose_target()

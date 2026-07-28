extends CharacterBody2D
class_name Chicken

enum State {
	WALKING,
	DASHING,
	HIDDEN,
	STUNNED,
	CAUGHT
}

var current_state: State = State.WALKING

@export var player_id: String = "p1"
@export var speed: float = 200.0
@export var dash_speed_multiplier: float = 3.5
@export var dash_duration: float = 0.25
@export var dash_cooldown: float = 3.0

var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var stun_timer: float = 0.0
var score: int = 0
var last_direction: String = "down"
var in_hiding_zone: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Signal emitted when the chicken drops worms (handled in a later milestone)
signal on_worms_dropped(amount: int, drop_position: Vector2)

func set_state(new_state: State) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	
	if current_state == State.DASHING:
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown
		velocity = velocity.normalized() * (speed * dash_speed_multiplier)

# --- INTERACTION API ---

func can_be_detected() -> bool:
	return current_state != State.HIDDEN

func set_hidden(hidden: bool) -> void:
	in_hiding_zone = hidden
	if hidden:
		if current_state == State.WALKING:
			set_state(State.HIDDEN)
	else:
		if current_state == State.HIDDEN:
			set_state(State.WALKING)

func take_hit(stun_dur: float, worms_lost: int, knockback_vel: Vector2 = Vector2.ZERO) -> void:
	if current_state == State.DASHING or current_state == State.STUNNED or current_state == State.CAUGHT:
		return
		
	set_state(State.STUNNED)
	stun_timer = stun_dur
	
	var actual_lost = min(score, worms_lost)
	score -= actual_lost
	velocity = knockback_vel
	
	if actual_lost > 0:
		SignalBus.spawn_dropped_worms.emit(actual_lost, global_position)
		SignalBus.spawn_floating_text.emit("-%d" % actual_lost, global_position + Vector2(0, -20), Color(0.9, 0.2, 0.2))
		
	SignalBus.screen_shake_requested.emit(8.0, 0.2)
	SignalBus.spawn_particles.emit(global_position, Color(0.9, 0.9, 0.9))
	_hit_flash()

# -----------------------

func _physics_process(delta: float) -> void:
	_handle_cooldowns(delta)
	
	match current_state:
		State.STUNNED:
			_handle_stun(delta)
		State.DASHING:
			_handle_dashing(delta)
		State.WALKING, State.HIDDEN:
			_handle_movement(delta)
			_handle_dash_input()
		State.CAUGHT:
			velocity = Vector2.ZERO
			
	move_and_slide()
	
	if current_state == State.DASHING:
		for i in get_slide_collision_count():
			var coll = get_slide_collision(i)
			var collider = coll.get_collider()
			if collider is Chicken and collider != self and collider.current_state != State.STUNNED:
				var knockback = -coll.get_normal() * speed * 2.0
				collider.take_hit(2.0, 2, knockback)
				velocity = coll.get_normal() * speed
				_revert_state()
				
	_process_animations()

func _revert_state() -> void:
	if in_hiding_zone:
		set_state(State.HIDDEN)
	else:
		set_state(State.WALKING)

func _handle_movement(_delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left_" + player_id, "move_right_" + player_id, "move_up_" + player_id, "move_down_" + player_id)
	velocity = input_dir * speed

func _handle_dash_input() -> void:
	if Input.is_action_just_pressed("dash_" + player_id) and dash_cooldown_timer <= 0.0 and velocity.length() > 0:
		set_state(State.DASHING)

func _handle_dashing(delta: float) -> void:
	dash_timer -= delta
	if dash_timer <= 0.0:
		_revert_state()

func _handle_cooldowns(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

func _handle_stun(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, speed * 4.0 * delta)
	stun_timer -= delta
	if stun_timer <= 0.0:
		_revert_state()

func _process_animations() -> void:
	if not anim: return
	
	match current_state:
		State.STUNNED, State.CAUGHT:
			anim.play("stunned")
			return
		_:
			pass
			
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

func _hit_flash() -> void:
	if anim:
		anim.modulate = Color(0.9, 0.2, 0.2)
		var tween = create_tween()
		tween.tween_property(anim, "modulate", Color.WHITE, 0.3)

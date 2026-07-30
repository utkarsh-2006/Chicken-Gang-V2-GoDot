extends CharacterBody2D
class_name AmbientAnimal

enum State {
	IDLE,
	WANDER
}

@export var move_speed: float = 25.0
@export var min_idle_duration: float = 1.5
@export var max_idle_duration: float = 4.0
@export var min_wander_duration: float = 1.5
@export var max_wander_duration: float = 4.0
@export var show_debug: bool = false

var current_state: State = State.IDLE
var last_direction: String = "down"
var wander_direction: Vector2 = Vector2.ZERO
var state_timer: float = 0.0
var animal_config: Dictionary = {}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if not animal_config.is_empty():
		_apply_config()
	_enter_idle()

func setup_animal(config: Dictionary) -> void:
	animal_config = config
	if anim != null:
		_apply_config()

func _apply_config() -> void:
	var config = animal_config
	if anim and config.has("frames"):
		anim.sprite_frames = config.frames
		# Start playing immediately so first frame renders correctly
		anim.play("idle_" + last_direction)
		
	if col_shape and config.has("collision_size") and config.has("collision_offset"):
		var shape = RectangleShape2D.new()
		shape.size = config.collision_size
		col_shape.shape = shape
		col_shape.position = config.collision_offset
		
	if config.has("move_speed"):
		move_speed = config.move_speed
	if config.has("min_idle_duration"):
		min_idle_duration = config.min_idle_duration
	if config.has("max_idle_duration"):
		max_idle_duration = config.max_idle_duration
	if config.has("min_wander_duration"):
		min_wander_duration = config.min_wander_duration
	if config.has("max_wander_duration"):
		max_wander_duration = config.max_wander_duration

func _physics_process(delta: float) -> void:
	if current_state == State.WANDER:
		velocity = wander_direction * move_speed
		var collided = move_and_slide()
		
		# Stop instantly on wall hit
		if collided:
			_enter_idle()
			return
			
	state_timer -= delta
	if state_timer <= 0.0:
		if current_state == State.IDLE:
			_enter_wander()
		else:
			_enter_idle()

	if show_debug:
		queue_redraw()

func _enter_idle() -> void:
	current_state = State.IDLE
	velocity = Vector2.ZERO
	state_timer = randf_range(min_idle_duration, max_idle_duration)
	
	if anim:
		anim.play("idle_" + last_direction)

func _enter_wander() -> void:
	current_state = State.WANDER
	state_timer = randf_range(min_wander_duration, max_wander_duration)
	
	# Prefer cardinal or gently normalized directions
	var angle = randf_range(0, TAU)
	wander_direction = Vector2(cos(angle), sin(angle)).normalized()
	
	_update_animation_direction()

func _update_animation_direction() -> void:
	if not anim: return
	
	if abs(wander_direction.x) > abs(wander_direction.y):
		if wander_direction.x > 0:
			last_direction = "right"
		else:
			last_direction = "left"
	else:
		if wander_direction.y > 0:
			last_direction = "down"
		else:
			last_direction = "up"
			
	anim.play("walk_" + last_direction)

func _draw() -> void:
	if not show_debug:
		return
		
	if current_state == State.WANDER:
		draw_line(Vector2.ZERO, wander_direction * 20.0, Color.GREEN, 2.0)
		
	var font = ThemeDB.fallback_font
	var font_size = 12
	var debug_str = "Family: " + animal_config.get("family_name", "UNKNOWN") + "\n"
	debug_str += "State: " + ("IDLE" if current_state == State.IDLE else "WANDER") + "\n"
	debug_str += "Speed: %.1f" % move_speed
	
	draw_string(font, Vector2(-30, -20), debug_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

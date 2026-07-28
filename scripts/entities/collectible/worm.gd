extends Area2D
class_name Worm

enum WormType {
	COMMON,
	RARE,
	GOLDEN,
	EVENT
}

@export var worm_type: WormType = WormType.COMMON
@export var value: int = 1
@export var golden_value: int = 5
@export var lifespan: float = 0.0 # 0 means infinite (permanent map worm)
@export var collect_delay: float = 0.0
@export var respawn_time: float = 15.0

var can_collect: bool = true
var is_active: bool = true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if worm_type == WormType.GOLDEN:
		value = golden_value
		if anim:
			anim.modulate = Color(0.945, 0.768, 0.058) 
	else:
		if anim:
			anim.modulate = Color.WHITE

	body_entered.connect(_on_body_entered)
	
	_start_floating_tween()

	if collect_delay > 0.0:
		can_collect = false
		modulate.a = 0.5
		get_tree().create_timer(collect_delay).timeout.connect(func():
			can_collect = true
			modulate.a = 1.0
		)
		
	if lifespan > 0.0:
		get_tree().create_timer(lifespan).timeout.connect(queue_free)

func _start_floating_tween() -> void:
	if not anim: return
	
	# Randomize start so they don't all bob in perfect sync
	anim.position.y = 0.0
	var tween = create_tween().set_loops()
	tween.tween_property(anim, "position:y", -4.0, 0.6).as_relative().set_trans(Tween.TRANS_SINE)
	tween.tween_property(anim, "position:y", 4.0, 0.6).as_relative().set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D) -> void:
	if not can_collect or not is_active:
		return
		
	if body is Chicken and body.current_state != Chicken.State.STUNNED:
		body.score += value
		SignalBus.spawn_floating_text.emit("+%d" % value, global_position, Color(1.0, 0.8, 0.2) if worm_type == WormType.GOLDEN else Color.WHITE)
		_collect_sequence()

func _collect_sequence() -> void:
	is_active = false
	can_collect = false
	collision.set_deferred("disabled", true)
	
	# Small bounce tween
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.15)
	
	tween.finished.connect(_on_collected_visuals_done)

func _on_collected_visuals_done() -> void:
	if lifespan > 0.0:
		# It's a dropped worm, destroy it
		queue_free()
	else:
		# It's a permanent map worm, hide and wait to respawn
		visible = false
		get_tree().create_timer(respawn_time).timeout.connect(_respawn)

func _respawn() -> void:
	is_active = true
	can_collect = true
	scale = Vector2.ONE
	visible = true
	collision.set_deferred("disabled", false)
	
	# Small pop-in animation
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

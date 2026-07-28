extends Node

# Juice & Feedback Signals
signal screen_shake_requested(intensity: float, duration: float)
signal spawn_floating_text(text: String, global_pos: Vector2, color: Color)
signal spawn_particles(global_pos: Vector2, color: Color)

# Gameplay Event Signals
signal spawn_dropped_worms(amount: int, center_position: Vector2)

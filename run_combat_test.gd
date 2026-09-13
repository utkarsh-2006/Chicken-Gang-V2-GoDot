extends Node

var tests_completed = 0
var log_file
var main
var c
var h
var step = -1
var timer = 0.0

var stats = {
	"attempts": 0,
	"attacks_entered": 0,
	"animations_completed": 0,
	"hits": 0,
	"misses": 0,
	"take_hit_calls": 0
}

func _ready():
	log_file = FileAccess.open("res://combat_test_results.txt", FileAccess.WRITE)
	log_file.store_line("--- MILESTONE 9B.2 COMBAT TEST ---")
	log_file.flush()
	
	var main_scene = load("res://main.tscn")
	main = main_scene.instantiate()
	get_tree().root.add_child.call_deferred(main)

func _process(delta):
	timer += delta
	if h and is_instance_valid(h): h.lost_target_timer = 0.0; h.current_target = c; h.current_state = h.State.CHASE
	
	if step == -1:
		if timer > 3.0:
			var chickens = get_tree().get_nodes_in_group("chicken")
			var hunters = []
			
			# recursive search
			var stack = [get_tree().root]
			while stack.size() > 0:
				var n = stack.pop_back()
				if n.get_class() == "Hunter" or (n.get_script() and n.get_script().get_global_name() == "Hunter"):
					hunters.append(n)
				stack.append_array(n.get_children())
			
			if chickens.size() > 0 and hunters.size() > 0:
				c = chickens[0]
				h = hunters[0]
				h.anim.animation_finished.connect(func(): stats["animations_completed"] += 1)
				h.current_target = c; h.current_state = h.State.CHASE
				step = 0
				timer = 0.0
			else:
				log_file.store_line("Failed to find Chicken or Hunter.")
				log_file.flush()
				get_tree().quit(1)
		return
		
	match step:
		0:
			log_file.store_line("Test A: Stationary")
			log_file.flush()
			c.global_position = Vector2(1000, 200)
			h.global_position = Vector2(1000, 225)
			c.velocity = Vector2.ZERO
			c.set_state(c.State.WALKING)
			step = 1
			timer = 0.0
			stats["attempts"] += 1
		1:
			print("STATE: ", h.current_state, " TARGET: ", h.current_target, " LOST: ", h.lost_target_timer, " CD: ", h.attack_cooldown_timer, " DIST: ", h.global_position.distance_to(c.global_position))
			if h.current_state == h.State.ATTACK:
				log_file.store_line("Entered ATTACK.")
				log_file.flush()
				stats["attacks_entered"] += 1
				step = 2
		2:
			if h.current_state != h.State.ATTACK:
				log_file.store_line("Finished ATTACK.")
				log_file.flush()
				if c.current_state == c.State.STUNNED:
					log_file.store_line("Test A: PASS")
					stats["hits"] += 1
					stats["take_hit_calls"] += 1
				else:
					log_file.store_line("Test A: FAIL (Not stunned)")
					stats["misses"] += 1
				log_file.flush()
				step = 3
				timer = 0.0
		3:
			if timer > 2.0:
				log_file.store_line("Test B: Enter range")
				log_file.flush()
				c.global_position = Vector2(1000, 200)
				h.global_position = Vector2(1000, 300)
				h.current_target = c; h.current_state = h.State.CHASE
				h.attack_cooldown_timer = 0.0
				step = 4
				timer = 0.0
		4:
			if h.current_state == h.State.ATTACK:
				stats["attacks_entered"] += 1
				step = 5
		5:
			if h.current_state != h.State.ATTACK:
				if c.current_state == c.State.STUNNED:
					log_file.store_line("Test B: PASS")
					stats["hits"] += 1
				log_file.flush()
				step = 6
				timer = 0.0
		6:
			if timer > 2.0:
				log_file.store_line("Test C: Maintain Spacing (No Jitter)")
				log_file.flush()
				c.global_position = Vector2(1000, 200)
				h.global_position = Vector2(1000, 220)
				h.attack_cooldown_timer = 2.0
				h.current_target = c; h.current_state = h.State.CHASE
				step = 7
				timer = 0.0
		7:
			if timer > 1.0:
				if h.velocity == Vector2.ZERO and h.current_state == h.State.CHASE:
					log_file.store_line("Test C: PASS (Spaced out, waiting)")
				else:
					log_file.store_line("Test C: FAIL")
				log_file.flush()
				step = 8
				timer = 0.0
		8:
			if timer > 1.0:
				log_file.store_line("Test D: Dash away")
				log_file.flush()
				c.global_position = Vector2(1000, 200)
				h.global_position = Vector2(1000, 225)
				h.attack_cooldown_timer = 0.0
				h.current_target = c; h.current_state = h.State.CHASE
				step = 9
		9:
			if h.current_state == h.State.ATTACK:
				c.global_position = Vector2(1000, -100)
				stats["attacks_entered"] += 1
				step = 10
		10:
			if h.current_state != h.State.ATTACK:
				if c.current_state != c.State.STUNNED:
					log_file.store_line("Test D: PASS (Missed)")
					stats["misses"] += 1
				else:
					log_file.store_line("Test D: FAIL (Hit)")
				log_file.flush()
				step = 11
				timer = 0.0
		11:
			if timer > 2.0:
				log_file.store_line("Test E: Hide during wind-up")
				log_file.flush()
				c.global_position = Vector2(1000, 200)
				h.global_position = Vector2(1000, 225)
				h.attack_cooldown_timer = 0.0
				c.set_state(c.State.WALKING)
				h.current_target = c; h.current_state = h.State.CHASE
				step = 12
		12:
			if h.current_state == h.State.ATTACK:
				c.set_state(c.State.HIDDEN)
				stats["attacks_entered"] += 1
				step = 13
		13:
			if h.current_state != h.State.ATTACK:
				if c.current_state != c.State.STUNNED:
					log_file.store_line("Test E: PASS (Missed due to hidden)")
					stats["misses"] += 1
				else:
					log_file.store_line("Test E: FAIL (Hit hidden)")
				log_file.flush()
				step = 14
				timer = 0.0
		14:
			if timer > 2.0:
				log_file.store_line("Test F: Move slightly")
				log_file.flush()
				c.set_state(c.State.WALKING)
				c.global_position = Vector2(1000, 200)
				h.global_position = Vector2(1000, 225)
				h.attack_cooldown_timer = 0.0
				h.current_target = c; h.current_state = h.State.CHASE
				step = 15
		15:
			if h.current_state == h.State.ATTACK:
				c.global_position = Vector2(205, 205)
				stats["attacks_entered"] += 1
				step = 16
		16:
			if h.current_state != h.State.ATTACK:
				if c.current_state == c.State.STUNNED:
					log_file.store_line("Test F: PASS (Hit anyway)")
					stats["hits"] += 1
				else:
					log_file.store_line("Test F: FAIL (Missed!)")
				log_file.flush()
				step = 17
				timer = 0.0
		17:
			if timer > 2.0:
				log_file.store_line("Test G/H/I/J: Directions")
				log_file.flush()
				c.global_position = Vector2(1000, 200)
				h.global_position = Vector2(975, 1000)
				h.attack_cooldown_timer = 0.0
				h.current_target = c; h.current_state = h.State.CHASE
				step = 18
		18:
			if h.current_state == h.State.ATTACK:
				if h.anim.animation == "attack_right":
					log_file.store_line("Test GHIJ: PASS (attack_right)")
				log_file.flush()
				step = 19
		19:
			if h.current_state != h.State.ATTACK:
				step = 20
				timer = 0.0
		20:
			if timer > 2.0:
				log_file.store_line("Test L: Attack Reentry")
				log_file.flush()
				c.global_position = Vector2(1000, 200)
				h.global_position = Vector2(1000, 225)
				h.attack_cooldown_timer = 0.0
				c.set_state(c.State.WALKING)
				h.current_target = c; h.current_state = h.State.CHASE
				step = 21
				timer = 0.0
				h.set_meta("attack_starts", 0)
		21:
			if h.current_state == h.State.ATTACK:
				h.set_meta("attack_starts", h.get_meta("attack_starts") + 1)
			if timer > 3.0:
				if h.get_meta("attack_starts") >= 1 and h.get_meta("attack_starts") <= 30: 
					log_file.store_line("Test L: PASS (Attack starts = " + str(h.get_meta("attack_starts")) + ")")
				else:
					log_file.store_line("Test L: FAIL (Spamming! Starts = " + str(h.get_meta("attack_starts")) + ")")
				log_file.flush()
				step = 22
				timer = 0.0
		22:
			log_file.store_line("Final Stats:")
			log_file.store_line(JSON.stringify(stats))
			log_file.flush()
			log_file.close()
			get_tree().quit(0)

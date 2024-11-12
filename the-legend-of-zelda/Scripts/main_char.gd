extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
enum state {IDLE, WALK_UP, WALK_DOWN, WALK_RIGHT, WALK_LEFT, MELEE}
var player_state = state.IDLE
var last_direction = state.WALK_LEFT  # Tracks last movement direction
var is_attacking = false  # Track if a melee attack is in progress
var isLeft

func update_animation():
	if player_state == state.MELEE and not is_attacking:
		is_attacking = true  # Set attacking flag
		match last_direction:
			state.WALK_LEFT:
				animated_sprite_2d.play("melee_left")
			state.WALK_RIGHT:
				animated_sprite_2d.play("melee_left")
			state.WALK_UP:
				animated_sprite_2d.play("melee_up")
			state.WALK_DOWN:
				animated_sprite_2d.play("melee_down")
		await animated_sprite_2d.animation_finished
		is_attacking = false
		player_state = state.IDLE
	elif player_state != state.MELEE:
		match player_state:
			state.WALK_LEFT:
				animated_sprite_2d.play("walk_left")
				last_direction = state.WALK_LEFT
			state.WALK_RIGHT:
				animated_sprite_2d.play("walk_right")
				last_direction = state.WALK_RIGHT
			state.WALK_DOWN:
				animated_sprite_2d.play("walk_down")
				last_direction = state.WALK_DOWN
			state.WALK_UP:
				animated_sprite_2d.play("walk_up")
				last_direction = state.WALK_UP
			state.IDLE:
				animated_sprite_2d.stop()  # Stop animation when idle

func _physics_process(delta: float) -> void:
	# Capture input for horizontal and vertical movement
	var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	var vertical_input = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# Handle attack action
	if Input.is_action_just_pressed("attack") and not is_attacking:
		player_state = state.MELEE
		update_animation()
		return  # Prevent movement while attacking
	
	# Handle movement input if not attacking
	if not is_attacking:
		if horizontal_input != 0:
			# Horizontal movement takes priority
			player_state = state.WALK_RIGHT if horizontal_input > 0 else state.WALK_LEFT
			velocity = Vector2(horizontal_input, 0).normalized() * SPEED
		elif vertical_input != 0:
			# Vertical movement only if no horizontal input
			player_state = state.WALK_DOWN if vertical_input > 0 else state.WALK_UP
			velocity = Vector2(0, vertical_input).normalized() * SPEED
		else:
			# No input means idle state
			player_state = state.IDLE
			velocity = Vector2.ZERO
		
		update_animation()
	isLeft = velocity.x < 0
	animated_sprite_2d.flip_h = isLeft
	
	move_and_slide()

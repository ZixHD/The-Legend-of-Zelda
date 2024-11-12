extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
enum state {IDLE, WALK_UP, WALK_DOWN, WALK_RIGHT, WALK_LEFT, MELEE}
var player_state = state.IDLE
var isLeft
var is_attacking = false  # Track if a melee attack is in progress

func update_animation():
	match(player_state):
		state.WALK_LEFT:
			animated_sprite_2d.play("walk_left")
			await animated_sprite_2d.animation_finished
			player_state = state.IDLE
			
		state.WALK_RIGHT:
			animated_sprite_2d.play("walk_right")
			await animated_sprite_2d.animation_finished
			player_state = state.IDLE
			
		state.WALK_DOWN:
			animated_sprite_2d.play("walk_down")
			await animated_sprite_2d.animation_finished
			player_state = state.IDLE
			
		state.WALK_UP:
			animated_sprite_2d.play("walk_up")
			await animated_sprite_2d.animation_finished
			player_state = state.IDLE
		
		state.MELEE:
			is_attacking = true  # Set attacking flag
			animated_sprite_2d.play("melee_left")
			await animated_sprite_2d.animation_finished
			is_attacking = false  # Reset flag after animation finishes
			player_state = state.IDLE
		
		state.IDLE:
			animated_sprite_2d.stop()

func _physics_process(delta: float) -> void:
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		player_state = state.MELEE
		update_animation()
	
	if input_direction != Vector2.ZERO and not is_attacking:
		# Determine the direction and set player_state accordingly
		if input_direction.x < 0:
			player_state = state.WALK_LEFT
		elif input_direction.x > 0:
			player_state = state.WALK_RIGHT
		elif input_direction.y < 0:
			player_state = state.WALK_UP
		elif input_direction.y > 0:
			player_state = state.WALK_DOWN
		
		# Update the velocity and animate based on direction
		velocity = input_direction * SPEED
		update_animation()
	elif not is_attacking:
		player_state = state.IDLE
		velocity = Vector2.ZERO  # Stop when no input is given

	# Set flip_h based on direction
	isLeft = velocity.x < 0
	animated_sprite_2d.flip_h = isLeft
	
	move_and_slide()

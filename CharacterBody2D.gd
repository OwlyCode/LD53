extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_on_floor = 0.0
var sliding = false
var slide_jump = false

func _ready():
	$AnimatedSprite2D.play()

func _physics_process(delta):
	if sliding:
		velocity.x = get_real_velocity().x
	else:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			slide_jump = false
			velocity.x = direction * SPEED
		else:
			if not slide_jump:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			else:
				velocity.x = get_real_velocity().x

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and was_on_floor < 0.15:
		velocity.y = JUMP_VELOCITY
		if sliding:
			slide_jump = true

		sliding = false
	elif Input.is_action_pressed("ui_down") and is_on_floor():
		sliding = true
		velocity.y = SPEED * 2.0

	if is_on_floor():
		was_on_floor = 0.0
	else:
		was_on_floor += delta

	var last_motion = get_position_delta()


	if sliding and last_motion.y < -0.01:
		sliding = false

	if not is_on_floor():
		$AnimatedSprite2D.animation = "jump"
	else:
		if abs(last_motion.x) < 0.01:
			$AnimatedSprite2D.animation = "idle"
		elif last_motion.x > 0:
			if not sliding:
				$AnimatedSprite2D.animation = "walk_right"
			else:
				$AnimatedSprite2D.animation = "slide_right"
		else:
			if not sliding:
				$AnimatedSprite2D.animation = "walk_left"
			else:
				$AnimatedSprite2D.animation = "slide_left"

	move_and_slide()

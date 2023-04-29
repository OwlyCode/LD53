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
	if not is_on_floor():
		sliding = false

	if sliding:
		velocity.x = get_real_velocity().x
	else:
		var direction = Input.get_axis("left", "right")
		if direction:
			slide_jump = false

			if abs(get_real_velocity().x) > abs(direction * SPEED) and sign(get_real_velocity().x) == sign(direction) and not is_on_floor():
				velocity.x = get_real_velocity().x
			else:
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
	if Input.is_action_just_pressed("jump") and was_on_floor < 0.15:
		velocity.y = JUMP_VELOCITY
		if sliding:
			slide_jump = true

		sliding = false
	elif Input.is_action_pressed("slide") and is_on_floor_only():
		if  (0.6 < get_floor_angle() and get_floor_angle() < 0.8) or (-0.8 < get_floor_angle() and get_floor_angle() < -0.6):
			sliding = true
			velocity.y = SPEED * 2.0

	if is_on_floor():
		was_on_floor = 0.0
	else:
		was_on_floor += delta

	var last_motion = get_position_delta()

	if sliding and last_motion.y <= 0.0:
		sliding = false

	print(is_on_floor())

	if not is_on_floor():
		$AnimatedSprite2D.animation = "jump"
	else:
		$AnimatedSprite2D.animation = "idle"

		if last_motion.x > 0:
			if not sliding:
				$AnimatedSprite2D.animation = "walk_right"
			else:
				$AnimatedSprite2D.animation = "slide_right"
				$CollisionShape2D.rotation_degrees = -45
		elif last_motion.x < 0:
			if not sliding:
				$AnimatedSprite2D.animation = "walk_left"
			else:
				$AnimatedSprite2D.animation = "slide_left"
				$CollisionShape2D.rotation_degrees = 45

	move_and_slide()

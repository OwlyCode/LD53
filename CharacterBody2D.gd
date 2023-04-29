extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_on_floor = 0.0
var sliding = false
var slide_jump = false
var max_shoot_power = 800.0
var shoot_power = 200.0
var initial_shoot_power = 200.0
var parcel = preload("res://prefabs/parcel.tscn");
var load_speed = 250.0
var has_parcel = true
var ended = false

func _ready():
	$AnimatedSprite2D.play()

func reach_goal():
	if has_parcel:
		ended = true

		return true

	return false

func update_trajectory(delta, initial_velocity):
	var line = $Line2D
	var max_points = 512

	line.clear_points()
	var pos = Vector2.ZERO
	var vel = initial_velocity

	for i in max_points:
		line.add_point(pos)
		vel.y += 0.55 * gravity * delta
		pos += vel * delta

		var query = PhysicsPointQueryParameters2D.new()
		query.position = transform.get_origin() + pos
		query.collision_mask = 0b00000000000000000100

		var intersections = get_world_2d().get_direct_space_state().intersect_point(query);
		if len(intersections) > 0:
			break


func _physics_process(delta):
	Engine.time_scale = 1.0

	if Input.is_action_just_pressed("restart"):
		get_node("/root/Game").restart()


	if has_parcel and not is_on_floor() and not ended:
		if Input.is_action_pressed("shoot"):
			Engine.time_scale = 0.2

	if has_parcel and not ended and Input.is_action_pressed("shoot"):
		var shoot_direction = (get_global_mouse_position() - transform.get_origin()).normalized()
		update_trajectory(0.005, shoot_direction * shoot_power)
		$Line2D.visible = true
		shoot_power = get_global_mouse_position().distance_squared_to(transform.get_origin()) / 100.0
		shoot_power = clampf(shoot_power, 0 , 800)

	if has_parcel and Input.is_action_just_released("shoot"):
		has_parcel = false
		$Line2D.visible = false
		var x = parcel.instantiate();
		get_tree().root.add_child(x)

		x.transform = transform
		var shoot_direction = (get_global_mouse_position() - transform.get_origin()).normalized()
		x.linear_velocity = shoot_direction * shoot_power
		x.angular_velocity = shoot_power / 10.0
		velocity += - shoot_direction * 350.0

	if not is_on_floor():
		sliding = false

	if sliding:
		velocity.x = get_real_velocity().x
	elif not ended:
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
	if Input.is_action_just_pressed("jump") and was_on_floor < 0.15 and not ended:
		velocity.y = JUMP_VELOCITY
		if sliding:
			slide_jump = true

		sliding = false
	elif Input.is_action_pressed("slide") and is_on_floor_only() and not ended:
		if  (0.6 < get_floor_angle() and get_floor_angle() < 0.8) or (-0.8 < get_floor_angle() and get_floor_angle() < -0.6):
			sliding = true
			velocity.y = SPEED * 1.5

	if is_on_floor():
		was_on_floor = 0.0
	else:
		was_on_floor += delta

	var last_motion = get_position_delta()

	if sliding and last_motion.y <= 0.0:
		sliding = false

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


	if ended:
		velocity = Vector2.ZERO

	move_and_slide()


	if sliding:
		$CPUParticles2D.emitting = true
	else:
		$CPUParticles2D.emitting = false

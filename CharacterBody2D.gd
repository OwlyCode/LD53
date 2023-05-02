extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -430.0

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
var moved = false
var pitch_scale = 1.0
var aiming = false
var shoot_canceled = false

var jump_cooldown = 0.0
var max_jump_cooldown = 0.3

func _ready():
	$AnimatedSprite2D.play()

func reach_goal():
	if has_parcel:
		ended = true

		return true

	return false

func update_trajectory(delta, initial_velocity):
	var line = $Line2D
	var max_points = 1024

	line.clear_points()
	var pos = Vector2.ZERO
	var vel = initial_velocity

	for i in max_points:
		line.add_point(pos)
		vel.y += 0.57 * gravity * delta
		pos += vel * delta

		var query = PhysicsPointQueryParameters2D.new()
		query.position = transform.get_origin() + pos
		query.collision_mask = 0b00000000000000000100

		var intersections = get_world_2d().get_direct_space_state().intersect_point(query);
		if len(intersections) > 0:
			break


func _physics_process(delta):
	var prefix = "carrying_"

	if not has_parcel:
		prefix = ""
		aiming = false
		$Line2D.visible = false

	Engine.time_scale = 1.0

	if Input.is_action_just_pressed("restart"):
		GameState.restart_level()


	if Input.is_action_just_pressed("level_select"):
		GameState.level_select()

	var pitching = false

	if has_parcel and not is_on_floor() and not ended:
		if Input.is_action_pressed("shoot") and aiming and not shoot_canceled:
			pitch_scale = clampf(pitch_scale - delta * 1.7, 0.25, 1.0)
			Engine.time_scale = 0.2
			pitching = true


	if not pitching:
		pitch_scale = clampf(pitch_scale + delta * 1.7, 0.25, 1.0)

	GameState.music_pitch(pitch_scale)

	if has_parcel and not ended and Input.is_action_pressed("shoot") and not shoot_canceled:
		var shoot_direction = (get_global_mouse_position() - transform.get_origin()).normalized()
		if not GameState.keyboard_mode:
			shoot_direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))

			if shoot_direction.length() < 0.1:
				shoot_direction = Vector2.RIGHT * 0.5 + Vector2.UP * 0.5

		$Line2D.visible = true
		if GameState.keyboard_mode:
			shoot_power = initial_shoot_power + get_global_mouse_position().distance_squared_to(transform.get_origin()) / 100.0
			shoot_power = clampf(shoot_power, 0 , 800)
		else:
			shoot_power = lerpf(initial_shoot_power, 800, shoot_direction.length())
		on_first_move()
		aiming = true

		update_trajectory(0.005, shoot_direction * shoot_power)

	$Line2D.default_color = Color.GREEN.lerp(Color.RED, shoot_power / max_shoot_power)

	if not ended and Input.is_action_pressed("cancel_shoot"):
		aiming = false
		shoot_canceled = true
		$Line2D.visible = false

	if not ended and Input.is_action_just_released("cancel_shoot"):
		shoot_canceled = false

	if has_parcel and Input.is_action_just_released("shoot") and aiming:
		has_parcel = false
		$Line2D.visible = false
		var x = parcel.instantiate();
		get_parent().add_child(x)
		on_first_move()
		aiming = false
		get_tree().call_group("dog", "switch_target", x)

		x.transform = transform

		var shoot_direction = (get_global_mouse_position() - transform.get_origin()).normalized()
		if not GameState.keyboard_mode:
			shoot_direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
			if shoot_direction.length() < 0.1:
				shoot_direction = Vector2.RIGHT * 0.5 + Vector2.UP * 0.5

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
			on_first_move()

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

	jump_cooldown = clampf(jump_cooldown - delta, -1, 1)

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and was_on_floor < 0.15 and not ended and jump_cooldown < 0.0:
		jump_cooldown = max_jump_cooldown
		$Jump.play()
		on_first_move()
		velocity.y = JUMP_VELOCITY
		if sliding:
			slide_jump = true

		sliding = false
	elif Input.is_action_pressed("slide") and is_on_floor_only() and not ended:
		on_first_move()
		if  (0.6 < get_floor_angle() and get_floor_angle() < 0.8) or (-0.8 < get_floor_angle() and get_floor_angle() < -0.6):
			sliding = true
			velocity.y = SPEED * 1.2
			velocity.x = clampf(velocity.x, -SPEED * 2, SPEED * 2)

	if is_on_floor():
		was_on_floor = 0.0
	else:
		was_on_floor += delta

	var last_motion = get_position_delta()

	if sliding and last_motion.y <= 0.0:
		sliding = false

	if not is_on_floor():
		if last_motion.x >= 0:
			switch_animation(prefix + "jump_right")
		else:
			switch_animation(prefix + "jump_left")
	else:
		if last_motion.x > 0:
			if not sliding:
				switch_animation(prefix + "walk_right")
			else:
				switch_animation(prefix + "slide_right")
				$CollisionShape2D.rotation_degrees = -45
		elif last_motion.x < 0:
			if not sliding:
				switch_animation(prefix + "walk_left")
			else:
				switch_animation(prefix + "slide_left")
				$CollisionShape2D.rotation_degrees = 45
		else:
			switch_animation(prefix + "idle")


	if ended:
		velocity = Vector2.ZERO

	move_and_slide()


	if sliding:
		$CPUParticles2D.emitting = true
	else:
		$CPUParticles2D.emitting = false


func switch_animation(anim):
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)


func _on_pickup_zone_body_entered(body):
	if body.immune_time <= 0 and not ended and body.pickable:
		get_tree().call_group("dog", "switch_target", self)
		has_parcel = true
		body.on_catch()
		$Pickup.play()


func on_first_move():
	if not moved:
		moved = true
		get_node("../GenericUI").start()

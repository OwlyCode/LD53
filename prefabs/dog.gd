extends CharacterBody2D


@export var patrol_distance = 10.0

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var start
var stop

var going_left = true

var angry = false

var target

var inertia = 0
var min_inertia = -400
var max_inertia = 400

var ended = false

var caught = false
var rethrow_timeout = 1.0
var happy = false

var shoot_power = 600
var parcel = preload("res://prefabs/parcel.tscn");

var rng = RandomNumberGenerator.new()

func _ready():
	start = position
	stop = position + Vector2.LEFT * patrol_distance
	$RunningParticles.emitting = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# var direction = Input.get_axis("ui_left", "ui_right")
	# if direction:
	# 	velocity.x = direction * SPEED
	# else:
	if happy:
		$AnimatedSprite2D.play("idle")
	elif caught:
		$AnimatedSprite2D.play("caught_parcel")
		inertia = 0
		velocity = Vector2.ZERO
		rethrow_timeout -= delta

		if rethrow_timeout < 0:
			happy = true
			rethrow()

	elif not angry and not ended:
		if going_left:
			velocity.x = -20
			$AnimatedSprite2D.play("walk_left")
		else:
			velocity.x = 20
			$AnimatedSprite2D.play("walk_right")

		if going_left and position.x < stop.x:
			going_left = false
		if not going_left and position.x > start.x:
			going_left = true
	elif not ended:
		if going_left:
			inertia = lerpf(inertia, min_inertia, 1.5 * delta)
			$AnimatedSprite2D.play("charge_left")
		else:
			inertia = lerpf(inertia, max_inertia, 1.5 * delta)
			$AnimatedSprite2D.play("charge_right")

		if position.x < target.position.x:
			going_left = false
		else:
			going_left = true

		inertia = clampf(inertia, min_inertia, max_inertia)
		velocity.x = inertia
	else:
		inertia = 0
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("idle")

	if not angry:
		inertia = 0

	$RunningParticles.emitting = not happy and (caught or abs(inertia) > 100.0)

	move_and_slide()


func _on_detection_zone_body_entered(body:Node2D):
	if angry or happy:
		return

	if "has_parcel" in body and body.has_parcel:
		angry = true
		target = body

	if "pickable" in body and body.pickable:
		angry = true
		target = body

func switch_target(t):
	if angry:
		target = t

func on_end_level():
	angry = false
	ended = true


func _on_bite_zone_body_entered(body):
	if happy:
		return

	if "has_parcel" in body and body.has_parcel:
		body.has_parcel = false
		angry = false
		caught = true

	if "pickable" in body and body.pickable:
		body.on_catch()
		angry = false
		caught = true

func rethrow():
	var x = parcel.instantiate();
	get_tree().root.add_child(x)
	get_tree().call_group("dog", "switch_target", x)

	x.transform = transform
	var shoot_direction = (Vector2.UP + Vector2.RIGHT * rng.randf_range(-0.5, 0.5)).normalized()
	x.linear_velocity = shoot_direction * shoot_power
	x.angular_velocity = shoot_power / 10.0

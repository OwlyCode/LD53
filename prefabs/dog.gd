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

func _ready():
	start = position
	stop = position + Vector2.LEFT * patrol_distance

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

	if not angry:
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
	else:
		if going_left:
			inertia = lerpf(inertia, min_inertia, 2*delta)
			$AnimatedSprite2D.play("charge_left")
		else:
			inertia = lerpf(inertia, max_inertia, 2*delta)
			$AnimatedSprite2D.play("charge_right")

		if position.x < target.position.x:
			going_left = false
		else:
			going_left = true

		inertia = clampf(inertia, min_inertia, max_inertia)
		velocity.x = inertia

	move_and_slide()


func _on_detection_zone_body_entered(body:Node2D):
	if angry:
		return

	if "has_parcel" in body and body.has_parcel:
		angry = true
		target = body

	if "pickable" in body and body.pickable:
		angry = true
		target = body

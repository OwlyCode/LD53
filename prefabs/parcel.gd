extends RigidBody2D

var reached = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$CPUParticles2D.emitting = linear_velocity.length() > 100.0

func _physics_process(_delta):
	if reached:
		rotation_degrees = 0
		linear_velocity = Vector2.ZERO

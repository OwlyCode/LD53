extends RigidBody2D

var reached = false
var caught = false

var immune_time = 0.2
var decay_time = 5.0

var pickable = true

func _process(delta):
	immune_time -= delta

	immune_time = clampf(immune_time, -1, 0.5)

	$CPUParticles2D.emitting = not caught && linear_velocity.length() > 100.0

	if caught:
		decay_time -= delta

	if decay_time < 0.0:
		queue_free()

func _physics_process(_delta):
	if reached:
		rotation_degrees = 0
		linear_velocity = Vector2.ZERO
	if caught:
		freeze = true

func on_catch():
	$Sprite2D.visible = false
	caught = true
	pickable = false


func _on_body_entered(_body:Node):
	var impact = linear_velocity.length() / 200

	if impact > 1:
		get_tree().call_group("effects", "camera_shake", linear_velocity.x / 100)
		$AudioStreamPlayer.play()

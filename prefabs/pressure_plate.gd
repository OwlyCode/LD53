extends Area2D

var pressed = false

@export var target: Array[NodePath]

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("off")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body:Node2D):
	if not pressed:
		pressed = true
		$AnimatedSprite2D.play("on")


		for t in target:
			var n = get_node(t)

			if is_instance_valid(n):
				n.plate_pressed()

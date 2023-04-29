extends RichTextLabel


var fading = false
var progress = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fading:
		progress += delta * 2.0

	if Input.is_action_pressed("shoot"):
		fade()
	if Input.is_action_pressed("shoot"):
		fade()
	if Input.is_action_just_released("shoot"):
		fade()
	if Input.is_action_pressed("left"):
		fade()
	if Input.is_action_pressed("right"):
		fade()
	if Input.is_action_pressed("jump"):
		fade()
	if Input.is_action_pressed("slide"):
		fade()

	modulate = Color.WHITE.lerp(Color.html("#FFFFFF33"), clampf(progress, 0.0, 1.0))

func fade():
	fading = true
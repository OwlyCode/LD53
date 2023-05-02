extends RichTextLabel

@export var keyboard_mode = true

var fading = false
var progress = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for action in InputMap.get_actions():
		var keys = []
		for event in InputMap.action_get_events(action):

			if event is InputEventKey and keyboard_mode:
				var key_name = OS.get_keycode_string(event.unicode).to_upper()

				if key_name == "":
					key_name = event.as_text()

				keys.append(key_name)

		if len(keys) > 0:
			print("%s -> %s" % [action, keys])
			text = text.replace("__%s__" % action, " or ".join(keys))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if keyboard_mode:
		visible = GameState.keyboard_mode
	else:
		visible = not GameState.keyboard_mode

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
	pass
	#fading = true
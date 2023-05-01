extends Button

@export var level: int = 0

var stars = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	text = "Level %d" % (level + 1)
	$Star3.modulate = Color.html("#55555555")
	$Star2.modulate = Color.html("#55555555")
	$Star1.modulate = Color.html("#55555555")

	refresh()

func refresh():
	stars = GameState.star_memory[level]

	if level > GameState.unlocked_level:
		disabled = true

	if stars == 3:
		$Star3.modulate = Color.WHITE

	if stars >= 2:
		$Star2.modulate = Color.WHITE

	if stars >= 1:
		$Star1.modulate = Color.WHITE


func _on_button_up():
	GameState.set_level(level)

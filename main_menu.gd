extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_credits_button_up():
	GameState.credits()

func _on_level_select_button_up():
	GameState.level_select()

func _on_start_button_up():
	GameState.start()

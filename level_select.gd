extends Node2D

var button = preload("res://prefabs/level_button.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var container = get_node("%GridContainer")

	for i in range(len(GameState.levels)):
		var x = button.instantiate()
		x.level = i
		container.add_child(x)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_back_button_up():
	GameState.main_menu()

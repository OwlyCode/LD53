extends Node2D

var levels = [
	preload("res://levels/level_1.tscn"),
	preload("res://levels/level_2.tscn"),
	preload("res://levels/level_3.tscn"),
	preload("res://levels/level_10.tscn"),
	preload("res://levels/level_x.tscn")
]

var current_level = 0
var inited = false

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if not inited:
		restart()
		inited = true

func next_level():
	current_level = (current_level + 1) % len(levels)
	restart()

func restart():
	for x in get_tree().root.get_children():
		if x.name != "Game":
			x.queue_free()
		else:
			for y in x.get_children():
				y.queue_free()

	var cl_color = RenderingServer.get_default_clear_color()
	RenderingServer.set_default_clear_color(Color.BLACK)

	await get_tree().create_timer(0.1).timeout

	RenderingServer.set_default_clear_color(cl_color)

	var cl = levels[current_level].instantiate()

	get_tree().root.add_child(cl)

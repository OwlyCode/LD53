extends Node2D

var levels = [
	#preload("res://levels/level_SJ1.tscn"), # Debug

	# Tutorial x3 (OK)
	preload("res://levels/level_A1.tscn"),
	preload("res://levels/level_A2.tscn"),
	preload("res://levels/level_A3.tscn"),

	# Dog intro x5 (manque 3)
	preload("res://levels/level_D1.tscn"),
	preload("res://levels/level_D2.tscn"),

	# Slide intro x5 (manque 1)
	preload("res://levels/level_S1.tscn"),
	preload("res://levels/level_S2.tscn"),
	preload("res://levels/level_S3.tscn"),
	preload("res://levels/level_S4.tscn"),

	# Parcel jump intro x5 (manque 2)
	preload("res://levels/level_SJ1.tscn"),
	preload("res://levels/level_SJ2.tscn"),
	preload("res://levels/level_SJ3.tscn")

	# Bonus (autant qu'on veut, plutot difficile car en fin de jeu)
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
				if y.name != "MusicLoop":
					y.queue_free()

	var cl_color = RenderingServer.get_default_clear_color()
	RenderingServer.set_default_clear_color(Color.BLACK)

	await get_tree().create_timer(0.1).timeout

	RenderingServer.set_default_clear_color(cl_color)

	var cl = levels[current_level].instantiate()

	get_tree().root.add_child(cl)

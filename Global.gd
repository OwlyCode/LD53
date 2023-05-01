extends Node

var current_level = 5
var max_levels = 20

var star_memory = []
var current_scene = null


var levels = [
	# Debug
	#preload("res://levels/level_S6.tscn"),

	# Tutorial
	preload("res://levels/level_A1.tscn"),
	preload("res://levels/level_A2.tscn"),
	preload("res://levels/level_A3.tscn"),

	# Dog intro
	preload("res://levels/level_D1.tscn"),
	preload("res://levels/level_D2.tscn"),
	preload("res://levels/level_D3.tscn"),
	preload("res://levels/level_D4.tscn"),
	preload("res://levels/level_D5.tscn"),

	# Slide
	preload("res://levels/level_S1.tscn"),
	preload("res://levels/level_S2.tscn"),
	preload("res://levels/level_S3.tscn"),
	preload("res://levels/level_S4.tscn"),
	preload("res://levels/level_S5.tscn"),
	preload("res://levels/level_S6.tscn"),

	# Parcel jump intro x5 (manque 1)
	preload("res://levels/level_SJ1.tscn"),
	preload("res://levels/level_SJ2.tscn"),
	preload("res://levels/level_SJ3.tscn"),
	preload("res://levels/level_SJ4.tscn")

	# Bonus (autant qu'on veut, plutot difficile car en fin de jeu)
]

var loading = false

func _ready():
	star_memory.resize(max_levels)
	star_memory.fill(0)

	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)

func set_level(level):
	if loading:
		return

	loading = true
	current_level = level
	GameState.goto_scene(levels[current_level])

func next_level():
	if current_level < max_levels:
		set_level(current_level + 1)

func restart_level():
	set_level(current_level)

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function from the running scene.
	# Deleting the current scene at this point might be
	# a bad idea, because it may be inside of a callback or function of it.
	# The worst case will be a crash or unexpected behavior.

	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(s):
	if is_instance_valid(current_scene):
		# Immediately free the current scene,
		# there is no risk here.
		current_scene.free()

		# Instance the new scene.
		current_scene = s.instantiate()

		# Add it to the active scene, as child of root.
		get_tree().get_root().add_child(current_scene)

		# Optional, to make it compatible with the SceneTree.change_scene() API.
		get_tree().set_current_scene(current_scene)
		loading = false

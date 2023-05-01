extends Node

var current_level = 0
var unlocked_level = 20

var star_memory = []
var current_scene = null

var m_menu = preload("res://main_menu.tscn")
var selector = preload("res://level_select.tscn")
var credits_scene = preload("res://credits.tscn")

var levels = [
	# Tutorial
	preload("res://levels/level_A1.tscn"),
	preload("res://levels/level_A2.tscn"),
	preload("res://levels/level_A3.tscn"),

	# Easy levels
	preload("res://levels/level_A4.tscn"),
	preload("res://levels/level_A5.tscn"),
	preload("res://levels/level_A6.tscn"),

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
	preload("res://levels/level_SJ3.tscn"),
	preload("res://levels/level_SJ4.tscn"),
	preload("res://levels/level_SJ5.tscn")

	# Bonus (autant qu'on veut, plutot difficile car en fin de jeu)
]

var loading = false
var game_music = AudioStreamPlayer.new()

func _ready():
	star_memory.resize(len(levels))
	star_memory.fill(0)

	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)

	game_music.stream = preload("res://art/game_music.ogg")
	game_music.autoplay = true

	add_child(game_music)
	game_music.stop()

func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.is_action_just_pressed("shoot"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func set_level(level):
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	if not game_music.playing:
		game_music.play()

	if loading:
		return

	loading = true
	current_level = level
	GameState.goto_scene(levels[current_level])

func level_select():
	game_music.stop()
	goto_scene(selector)

func main_menu():
	game_music.stop()
	goto_scene(m_menu)

func credits():
	game_music.stop()
	goto_scene(credits_scene)

func start():
	set_level(0)

func win_level(stars):
	star_memory[current_level] = max(star_memory[current_level], stars)
	if current_level == unlocked_level:
		unlocked_level += 1

func next_level():
	if current_level < len(levels) - 1:
		set_level(current_level + 1)
	else:
		credits()

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

func music_pitch(p):
	game_music.pitch_scale = p

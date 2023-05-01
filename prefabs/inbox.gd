extends Node2D

func _ready():
	get_node("InboxSprite").play("open")

func shake():
	get_node("InboxSprite").play("closed")
	for i in range(5):
		rotation_degrees -= 15
		await get_tree().create_timer(0.1).timeout
		rotation_degrees += 15
		await get_tree().create_timer(0.1).timeout

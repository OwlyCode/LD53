extends StaticBody2D

func plate_pressed():
	$AudioStreamPlayer.play()
	$Sprite2D.visible = false
	collision_layer = 0
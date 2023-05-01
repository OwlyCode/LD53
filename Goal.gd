extends Node2D

var ending = false

func _ready():
	get_node("Inbox/InboxSprite").play("open")

func _on_area_2d_body_entered(body:Node2D):
	if "reached" in body and not ending:
		body.reached = true
		$GoalReached.emitting = true
		ending = true
		get_node("../../GenericUI").end_level()
		$GoalSound.play()
		get_tree().call_group("dog", "on_end_level")
		get_node("Inbox/InboxSprite").play("closed")
		shake_inbox()

	if body.has_method("reach_goal"):
		if body.reach_goal() and not ending:
			$GoalReached.emitting = true
			ending = true
			get_node("../../GenericUI").end_level()
			$GoalSound.play()
			get_tree().call_group("dog", "on_end_level")
			get_node("Inbox/InboxSprite").play("closed")
			shake_inbox()

func shake_inbox():
	for i in range(5):
		$Inbox.rotation_degrees -= 15
		await get_tree().create_timer(0.1).timeout
		$Inbox.rotation_degrees += 15
		await get_tree().create_timer(0.1).timeout

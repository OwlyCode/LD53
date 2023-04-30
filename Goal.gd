extends Node2D

var ending = false

func _on_area_2d_body_entered(body:Node2D):
	if "reached" in body and not ending:
		body.reached = true
		$GoalReached.emitting = true
		ending = true
		get_node("../../GenericUI").end_level()
		$GoalSound.play()

	if body.has_method("reach_goal"):
		if body.reach_goal() and not ending:
			$GoalReached.emitting = true
			ending = true
			get_node("../../GenericUI").end_level()
			$GoalSound.play()

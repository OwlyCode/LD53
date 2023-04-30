extends Node2D

var ending = false

func _on_area_2d_body_entered(body:Node2D):
	if "reached" in body:
		body.reached = true
		$GoalReached.emitting = true
		ending = true
		get_node("../../GenericUI").end_level()

	if body.has_method("reach_goal"):
		if body.reach_goal():
			$GoalReached.emitting = true
			ending = true
			get_node("../../GenericUI").end_level()

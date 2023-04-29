extends Node2D

var end_delay = 3.0
var ending = false

func _on_area_2d_body_entered(body:Node2D):
	if "reached" in body:
		body.reached = true
		$GoalReached.emitting = true
		ending = true

	if body.has_method("reach_goal"):
		if body.reach_goal():
			$GoalReached.emitting = true
			ending = true

func _process(delta):
	if ending:
		end_delay -= delta

	if end_delay < 0.0:
		get_node("/root/Game").next_level()

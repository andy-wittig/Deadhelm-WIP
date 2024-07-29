extends Area2D

func _process(delta):
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				if (Input.is_action_just_pressed("move_up") || Input.is_action_just_pressed("move_down")):
					body.state = body.state_type.CLIMBING

func _on_body_exited(body):
	if (body.is_in_group("players")):
		if (!GameManager.multiplayer_mode_enabled ||
		body.player_id == multiplayer.get_unique_id()):
			body.state = body.state_type.MOVING

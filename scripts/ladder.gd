extends Area2D

func _process(delta):
	for area in get_overlapping_areas():
		if (area.is_in_group("players")):
			var body = area.get_parent()
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				if (Input.is_action_just_pressed("climb")):
					body.state = body.state_type.CLIMBING

func _on_area_exited(area):
	if (area.is_in_group("players")):
		var body = area.get_parent()
		if (!GameManager.multiplayer_mode_enabled ||
		body.player_id == multiplayer.get_unique_id()):
			if (body.state != body.state_type.ZIPLINE):
				body.state = body.state_type.MOVING

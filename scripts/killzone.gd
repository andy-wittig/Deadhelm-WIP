extends Area2D

func _on_body_entered(body):
	if (body.is_in_group("players")):
		if (!GameManager.multiplayer_mode_enabled): #single player
				body.hurt_player(100, global_position, 0)
		elif (multiplayer.is_server()): #multiplayer
			body.hurt_player.rpc_id(body.player_id, 100, global_position, 0)

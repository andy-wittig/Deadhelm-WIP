extends Area2D

@export var damage: int

var active := true

func _on_body_entered(body):
	if (active):
		if (body.is_in_group("players") && multiplayer.is_server()):
			if (body.get_name() == "player"): #single player
				body.hurt_player(damage, global_position.x)
			else: #multiplayer
				body.hurt_player.rpc_id(body.player_id, damage, global_position.x)

		

extends Area2D

func _on_body_entered(body):
	if (body.is_in_group("players")):
		body.hurt_player(1000, global_position, 0)

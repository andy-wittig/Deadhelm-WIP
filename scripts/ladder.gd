extends Area2D

enum state_type {
	MOVING,
	CLIMBING
}

func _on_body_entered(body):
	if (body.is_in_group("players")):
		body.state = state_type.CLIMBING

func _on_body_exited(body):
	if (body.is_in_group("players")):
		body.state = state_type.MOVING

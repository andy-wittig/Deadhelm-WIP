extends Area2D

const BOUNCE_VELOCITY = -350.0

func _ready():
	pass

func _process(delta):
	pass

func _on_body_entered(body):
	if (body.get_parent().get_name() == "players"):
		if (!body.grounded):
			body.velocity.y = BOUNCE_VELOCITY

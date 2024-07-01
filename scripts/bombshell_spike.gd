extends Area2D

var direction = Vector2(1.0,0.0)
const SPEED = 100.0

func on_ready():
	$DestroyTimer.start(0.6)

func _process(delta):
	self.rotation = direction.angle()
	position += direction * SPEED * delta

@rpc("call_local")
func destroy_self():
	queue_free()

func _on_destroy_timer_timeout():
	destroy_self()

func _on_body_entered(body):
	if (body.get_parent().get_name() == "players"
	&& multiplayer.is_server()):
		if (body.get_name() == "player"):
			body.hurt_player(15, global_position.x)
			destroy_self()
		else:
			body.hurt_player.rpc_id(body.player_id, 10, global_position.x)
			destroy_self()

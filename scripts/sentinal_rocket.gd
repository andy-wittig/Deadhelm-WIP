extends Area2D

var direction: Vector2
const SPEED = 80.0

func _process(delta):
	self.rotation = direction.angle()
	position += direction * SPEED * delta

@rpc("call_local")
func destroy_self():
	var explosion = load("res://scenes/vfx/explosion.tscn").instantiate()
	get_tree().get_root().add_child(explosion)
	explosion.position = position
	queue_free()

func _on_destroy_timer_timeout():
	destroy_self()

func _on_body_entered(body):
	if (body.get_parent().get_name() == "players"
	&& multiplayer.is_server()):
		if (body.get_name() == "player"):
			body.hurt_player(15, global_position, 200)
			destroy_self()
		else:
			body.hurt_player.rpc_id(body.player_id, 15, global_position, 200)
			rpc("destroy_self")

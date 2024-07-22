extends Area2D

const SPEED = 80.0
const ROCKET_KNOCK_BACK := 150

var direction: Vector2

func _process(delta):
	self.rotation = direction.angle()
	position += direction * SPEED * delta

@rpc("call_local")
func destroy_self():
	var explosion = load("res://scenes/vfx/explosion.tscn").instantiate()
	explosion.position = position
	get_parent().add_child(explosion)
	queue_free()

func _on_destroy_timer_timeout():
	destroy_self()

func _on_body_entered(body):
	if (body.is_in_group("players")):
		if (!GameManager.multiplayer_mode_enabled):
			body.hurt_player(15, global_position, ROCKET_KNOCK_BACK)
			destroy_self()
		elif (multiplayer.is_server()):
			body.hurt_player.rpc_id(body.player_id, 15, global_position, ROCKET_KNOCK_BACK)
			rpc("destroy_self")		

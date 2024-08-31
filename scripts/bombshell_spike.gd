extends Area2D

const SPEED = 100.0
const SPIKE_KNOCK_BACK := 100
const PLAYER_DAMAGE := 6

var direction = Vector2(1.0,0.0)

func _process(delta):
	self.rotation = direction.angle()
	position += direction * SPEED * delta

@rpc("call_local")
func destroy_self():
	queue_free()

func _on_destroy_timer_timeout():
	destroy_self()

func _on_body_entered(body):
	if (body.is_in_group("players")):
		if (!GameManager.multiplayer_mode_enabled):
			body.hurt_player(PLAYER_DAMAGE, global_position, SPIKE_KNOCK_BACK)
			destroy_self()
		elif (multiplayer.is_server()):
			body.hurt_player.rpc_id(body.player_id, PLAYER_DAMAGE, global_position, SPIKE_KNOCK_BACK)
			rpc("destroy_self")
			

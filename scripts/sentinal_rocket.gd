extends Area2D

const SPEED := 80.0
const ROCKET_KNOCK_BACK := 50
const PLAYER_DAMAGE := 10

var direction: Vector2

func _process(delta):
	rotation = direction.angle()
	global_position += direction * SPEED * delta

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
			body.hurt_player(PLAYER_DAMAGE, global_position, ROCKET_KNOCK_BACK)
			body.set_screen_shake(0.8)
			destroy_self()
		elif (multiplayer.is_server()):
			body.hurt_player.rpc_id(body.player_id, PLAYER_DAMAGE, global_position, ROCKET_KNOCK_BACK)
			#body.set_screen_shake(0.8) adjust for multiplayer
			rpc("destroy_self")		

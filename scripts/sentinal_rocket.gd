extends CharacterBody2D

var direction: Vector2
const SPEED = 80.0

func _process(_delta):
	self.rotation = direction.angle()
	velocity = direction * SPEED
	move_and_slide()

@rpc("any_peer", "call_local")
func destroy_self():
	var explosion = load("res://scenes/explosion.tscn").instantiate()
	get_parent().add_child(explosion)
	explosion.position = position
	queue_free()

func _on_destroy_timer_timeout():
	var explosion = load("res://scenes/explosion.tscn").instantiate()
	get_parent().add_child(explosion)
	explosion.position = self.position
	queue_free()
	
func _on_area_2d_body_entered(body):
	if (body.get_parent().get_name() == "players"
	&& multiplayer.is_server()):
		if (body.get_name() == "player"):
			body.hurt_player(15, global_position.x)
			destroy_self()
		else:
			body.hurt_player.rpc_id(body.player_id, 15, global_position.x)
			rpc("destroy_self")

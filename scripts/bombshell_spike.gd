extends CharacterBody2D

var direction = Vector2(1.0,0.0)
var speed = 100.0

func on_ready():
	$DestroyTimer.start(0.6)

func _process(_delta):
	self.rotation = velocity.angle()
	velocity = speed * direction
	move_and_slide()

func _on_destroy_timer_timeout():
	queue_free()
	
@rpc("any_peer", "call_local")
func destroy_self():
	queue_free()
	
func _on_area_2d_body_entered(body):
	if (body.get_parent().get_name() == "players"
	&& multiplayer.is_server()):
		if (body.get_name() == "player"):
			body.hurt_player(15, global_position.x)
			destroy_self()
		else:
			body.hurt_player.rpc_id(body.player_id, 10, global_position.x)
			rpc("destroy_self")	

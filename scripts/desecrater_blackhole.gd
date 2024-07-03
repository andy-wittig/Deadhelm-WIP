extends Area2D

var direction = Vector2(-1.0,0.0)
const SPEED = 20.0
const ATTRACTION_SPEED = 120.0

@onready var hurt_area = $HurtArea

func _physics_process(delta):
	position += direction * SPEED * delta
	
	for body in hurt_area.get_overlapping_bodies():
		if body.is_in_group("players"):
			body.velocity.x = ((global_position - body.global_position).normalized() * ATTRACTION_SPEED).x

@rpc("call_local")
func destroy_self():
	queue_free()

func _on_destroy_timer_timeout():
	destroy_self()

func _on_body_entered(body):
	if (body.is_in_group("players")
		&& multiplayer.is_server()):
			if (body.get_name() == "player"):
				body.hurt_player(20, global_position.x)
				destroy_self()
			else:
				body.hurt_player.rpc_id(body.player_id, 20, global_position.x)
				rpc("destroy_self")

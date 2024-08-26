extends Area2D

var direction = Vector2(-1.0,0.0)
const SPEED = 28.0
const ATTRACTION_SPEED = 135.0
const BLACKHOLE_KNOCK_BACK := 125

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
	if (body.is_in_group("players")):
		if (!GameManager.multiplayer_mode_enabled):
			body.hurt_player(20, global_position, BLACKHOLE_KNOCK_BACK)
			destroy_self()
		elif (multiplayer.is_server()):
			body.hurt_player.rpc_id(body.player_id, 20, global_position, BLACKHOLE_KNOCK_BACK)
			rpc("destroy_self")

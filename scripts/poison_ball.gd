extends Area2D

const SPEED := 60.0
const KNOCK_BACK := 30
const PLAYER_DAMAGE := 5

var direction: Vector2

func _process(delta):
	$Sprite2D.rotation = direction.angle()
	global_position += direction * SPEED * delta

func _on_destroy_timer_timeout():
	call_deferred("queue_free")

func _on_body_entered(body):
	if (body.is_in_group("players")):
		body.hurt_player(PLAYER_DAMAGE, global_position, KNOCK_BACK)
		body.set_screen_shake(0.4)
		call_deferred("queue_free")

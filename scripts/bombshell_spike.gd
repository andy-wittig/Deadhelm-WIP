extends Area2D

const SPEED := 100.0
const SPIKE_KNOCK_BACK := 45
const PLAYER_DAMAGE := 6

var direction := Vector2(1.0,0.0)

func _process(delta):
	self.rotation = direction.angle()
	position += direction * SPEED * delta

func _on_destroy_timer_timeout():
	$AnimationPlayer.play("fade_out")

func _on_body_entered(body):
	if (body.is_in_group("players")):
		body.hurt_player(PLAYER_DAMAGE, global_position, SPIKE_KNOCK_BACK)
		destroy_self()
		
func destroy_self():
	$AnimationPlayer.play("fade_out")

func _on_animation_player_animation_finished(anim_name):
	queue_free()

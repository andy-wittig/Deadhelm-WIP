extends Area2D

var direction : Vector2
const SPEED = 80.0

@onready var meteor_sprite = $MeteorSprite

func _process(delta):
	meteor_sprite.rotation = direction.angle()
	position += direction * SPEED * delta

func _on_destroy_timer_timeout():
	queue_free()
	
@rpc("any_peer", "call_local")
func destroy_self():
	queue_free()

func _on_body_entered(body):
	if (body.get_parent().get_name() == "enemies"
	&& multiplayer.is_server()):
		body.hurt_enemy.rpc(10, global_position.x)
		rpc("destroy_self")
		

extends Area2D

var direction := Vector2(-1.0,0.0)
const SPEED := 35.0
const ATTRACTION_SPEED := 15.0
const BLACKHOLE_KNOCK_BACK := 55
const PLAYER_DAMAGE := 10

@onready var hurt_area = $HurtArea

func _physics_process(delta):
	global_position += direction * SPEED * delta
	
	for body in hurt_area.get_overlapping_bodies():
		if body.is_in_group("players"):
			body.velocity.x += ((global_position - body.player_center.global_position).normalized() * ATTRACTION_SPEED).x

func destroy_self():
	queue_free()

func _on_destroy_timer_timeout():
	destroy_self()

func _on_body_entered(body):
	if (body.is_in_group("players")):
		body.hurt_player(PLAYER_DAMAGE, global_position, BLACKHOLE_KNOCK_BACK)
		destroy_self()

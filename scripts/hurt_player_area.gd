extends Area2D

@export var damage: int
@export var attack_wait := 2.0
var active := true

@onready var hurt_player_timer = $HurtPlayerTimer

func apply_damage(body):
	if (body.is_in_group("players") && active):
		if (!GameManager.multiplayer_mode_enabled): #single player
				body.hurt_player(damage, global_position, 100)
		elif (multiplayer.is_server()): #multiplayer
			body.hurt_player.rpc_id(body.player_id, damage, global_position, 100)	

func _on_body_entered(body):
		hurt_player_timer.wait_time = attack_wait
		hurt_player_timer.start()
		apply_damage(body)

func _on_body_exited(body):
	if (get_overlapping_bodies().size() < 1): #no players left
		hurt_player_timer.stop()

func _on_hurt_player_timer_timeout():
	for body in get_overlapping_bodies():
		apply_damage(body)



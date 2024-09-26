extends Area2D

@export var damage: int
@export var attack_wait := 2.0
@export var knock_back_force := 100

var active := true
var can_hurt := true


@onready var hurt_player_timer = $HurtPlayerTimer

func _process(_delta):
	if (active):
		if (get_overlapping_bodies().size() < 1):
			can_hurt = true
		for body in get_overlapping_bodies():
			if (body.is_in_group("players") && can_hurt):
				apply_damage(body)
				hurt_player_timer.start(attack_wait)
				can_hurt = false

func apply_damage(body):
	if (!GameManager.multiplayer_mode_enabled): #single player
			body.hurt_player(damage, global_position, knock_back_force)
	elif (multiplayer.is_server()): #multiplayer
		body.hurt_player.rpc_id(body.player_id, damage, global_position, knock_back_force)	
	
func _on_hurt_player_timer_timeout():
	can_hurt = true

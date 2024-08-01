extends Area2D

@export var damage: int
@export var attack_wait := 2.0

var active := true
var knock_back_force := 100

@onready var hurt_player_timer = $HurtPlayerTimer

func _process(_delta):
	if (hurt_player_timer.is_stopped() && active):
		for body in get_overlapping_bodies():
			if (body.is_in_group("players")):
				apply_damage(body)
				hurt_player_timer.start(attack_wait)

func apply_damage(body):
	if (!GameManager.multiplayer_mode_enabled): #single player
			body.hurt_player(damage, global_position, knock_back_force)
	elif (multiplayer.is_server()): #multiplayer
		body.hurt_player.rpc_id(body.player_id, damage, global_position, knock_back_force)	
	

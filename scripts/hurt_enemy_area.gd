extends Area2D

@export var damage: int
@export var attack_wait := 2.0
@export var destroy_time := 2

@onready var hurt_enemy_timer = $HurtEnemyTimer
@onready var destroy_timer = $DestroyTimer

@rpc("any_peer", "call_local")
func destroy_self():
	queue_free()

func _ready():
	destroy_timer.start(destroy_time)
	hurt_enemy_timer.wait_time = attack_wait
	hurt_enemy_timer.start()
	
func _on_hurt_enemy_timer_timeout():
	for body in get_overlapping_bodies():
		if (body.is_in_group("enemies")
		&& multiplayer.is_server()):
			body.hurt_enemy.rpc(damage, global_position.x)

func _on_destroy_timer_timeout():
	rpc("destroy_self")

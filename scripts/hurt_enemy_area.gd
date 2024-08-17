extends Area2D

@export var damage: int
@export var attack_wait := 2.0
@export var destroy_time := 2
@export var knock_back := 0.0
@export var shape: CollisionShape2D

@onready var hurt_enemy_timer = $HurtEnemyTimer
@onready var destroy_timer = $DestroyTimer

func _ready():
	$CollisionShape2D.set_shape(shape.get_shape())
	destroy_timer.start(destroy_time)
	hurt_enemy_timer.wait_time = attack_wait
	hurt_enemy_timer.start()
	
func _on_hurt_enemy_timer_timeout():
	for body in get_overlapping_bodies():
		if (body.is_in_group("enemies")):
			if (multiplayer.is_server()):
				body.hurt_enemy.rpc(damage, global_position, knock_back)
			elif (!GameManager.multiplayer_mode_enabled):
				body.hurt_enemy(damage, global_position, knock_back)

func _on_destroy_timer_timeout():
	queue_free()

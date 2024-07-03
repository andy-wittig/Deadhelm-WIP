extends Node2D

var attack_wait := false

@onready var ray_cast = $RayCast2D
@onready var attack_timer = $AttackTimer

func _process(_delta):
	if (not attack_wait):
		if (ray_cast.is_colliding()):
			var body = ray_cast.get_collider()
			if (body.get_parent().get_name() == "players"
			&& multiplayer.is_server()):
				rpc("attack")
				attack_timer.start()
				attack_wait = true

@rpc("call_local")
func attack():
	var blackhole = load("res://scenes/desecrater_blackhole.tscn").instantiate()
	blackhole.position = position
	get_tree().get_root().add_child(blackhole)

func _on_attack_timer_timeout():
	attack_wait = false

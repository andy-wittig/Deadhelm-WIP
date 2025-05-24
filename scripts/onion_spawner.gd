extends Area2D

@onready var onion_spawner = $"."
@onready var spawn_timer = $SpawnTimer
@onready var dirt_particles = $DirtParticles
@onready var animation_player = $AnimationPlayer

func _process(delta):
	for body in onion_spawner.get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (spawn_timer.time_left <= 0):
				animation_player.play("rock")
				dirt_particles.emitting = true
				spawn_timer.start()

func _on_spawn_timer_timeout():
	var onion = load("res://scenes/enemies/onion.tscn").instantiate()
	get_tree().get_root().get_node("game/Level").add_child(onion)
	onion.global_position = global_position
	onion.velocity.y = -180
	onion.reset_physics_interpolation()
	queue_free()

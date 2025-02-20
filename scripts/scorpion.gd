extends BaseEnemy

@onready var poison_ball_marker = $PoisonBallMarker

func start_enemy_attack():
	if (!attack_started):
		enemy_sprite.play("attack")
		if (enemy_sprite.frame == 4 && player != null):
			var poison_ball = load("res://scenes/enemies/poison_ball.tscn").instantiate()
			poison_ball.direction = (player.player_center.global_position - poison_ball_marker.global_position).normalized()
			poison_ball.global_position = poison_ball_marker.global_position
			get_parent().add_child(poison_ball)
			
			enemy_sprite.play("idle")
			attack_started = true
			
	velocity.x = 0

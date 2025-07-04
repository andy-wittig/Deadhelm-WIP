extends BaseEnemy

@onready var poison_ball_marker = $PoisonBallMarker

func start_enemy_attack():
	if (!attack_started):
		velocity.x = 0
		enemy_sprite.play("attack")
		if (enemy_sprite.frame == 4 && player != null):
			var poison_ball = load("res://scenes/enemies/poison_ball.tscn").instantiate()
			poison_ball.direction = (player.player_center.global_position - poison_ball_marker.global_position).normalized()
			poison_ball.global_position = poison_ball_marker.global_position
			get_parent().add_child(poison_ball)
			
			enemy_sprite.play("idle")
			dodge_player()
			attack_started = true
			attack_timer.start(attack_timer_wait)
			
func dodge_player():
	extra_h_velocity = -direction * DODGE_SPEED

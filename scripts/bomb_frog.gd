extends JumpingEnemy

var cooldown := 4

func start_enemy_attack():
	velocity.x = 0
	enemy_sprite.play("primed")
	
	if (animation_player.current_animation != "hurt_blink"):
		animation_player.play("blink")
	
	if (!attack_started):
		attack_started = true
		attack_timer.start(attack_timer_wait)

func attack_finished():
	enemy_sprite.play("idle")
	cooldown_timer.start(cooldown)
	if (chasing_player):
		detonate()
		state = state_type.MOVING

func detonate():
	var explosion = load("res://scenes/enemies/large_explosion.tscn").instantiate()
	explosion.position = position
	get_parent().add_child(explosion)
	
	player.set_screen_shake(0.8)

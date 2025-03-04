extends BaseEnemy

class_name JumpingEnemy

@export var HANG_TIME_THRESHHOLD := 40.0
@export var HANG_TIME_MULTIPLIER := 0.6

@export var jump_timer_wait : float

var jump_timer: float

func move_enemy(delta):
	if (!is_on_floor()):
		enemy_sprite.play("leap")
	else:
		enemy_sprite.play("idle")
	
	if (jump_timer <= 0):
		if (is_on_floor()):
			velocity.y = JUMP_VELOCITY
			jump_timer = jump_timer_wait
	else:
		jump_timer -= delta
		
		if right_raycast.is_colliding():
			direction = -1
		elif left_raycast.is_colliding():
			direction = 1
		
func chase_player(delta):
	if (player != null):
		#chase towards player's direction
		var distance_to_player = player.global_position.distance_to(global_position)
		direction = sign(player.global_position.x - global_position.x)
		
		if (distance_to_player > ATTACK_RANGE):
			if (!is_on_floor()):
				enemy_sprite.play("leap")
			else:
				enemy_sprite.play("idle")
				
			if (jump_timer <= 0):
				if (is_on_floor()):
					velocity.y = JUMP_VELOCITY
				jump_timer = jump_timer_wait
			else:
				jump_timer -= delta
		else: #player is within attacking range
			cooldown_timer.start(cooldown_timer_wait)
			enemy_sprite.stop()
			state = state_type.ATTACK

func calculate_velocity(delta):
	if (!is_on_floor()):
		velocity.x = direction * SPEED
		if (abs(velocity.y) < HANG_TIME_THRESHHOLD):
			velocity.y += gravity * HANG_TIME_MULTIPLIER * delta
		else:
			velocity.y += gravity * delta
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION_SPEED)
	
	if (abs(knock_back) > Vector2.ZERO):
		velocity = knock_back
		knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_FALLOFF)
		knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_FALLOFF)
	
	velocity.x += extra_h_velocity

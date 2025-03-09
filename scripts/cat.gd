extends BaseEnemy

@onready var choice_timer = $ChoiceTimer

func move_enemy(delta):
	enemy_sprite.play("run")
			
	if right_raycast.is_colliding():
		var choice = randi_range(0, 1)
		if (choice && choice_timer.time_left <= 0):
			direction = -1
		elif (is_on_floor()):
			choice_timer.start()
			velocity.y = JUMP_VELOCITY
	elif left_raycast.is_colliding():
		var choice = randi_range(0, 1)
		if (choice && choice_timer.time_left <= 0):
			direction = 1
		elif (is_on_floor()):
			choice_timer.start()
			velocity.y = JUMP_VELOCITY
		
	velocity.x = direction * SPEED

func _process(delta):
	pass

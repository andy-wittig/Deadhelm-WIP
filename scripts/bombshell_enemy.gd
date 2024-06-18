extends CharacterBody2D

const SPEED = 25.0
const JUMP_VELOCITY = -140.0

var direction = 1
var rand_state_timer = RandomNumberGenerator.new()

var chasing_player = false
var attacking = false
var attack_timer_started = false
var bombshell_detonated = false

enum state_type {
	MOVING,
	IDLE,
	CHASE,
	ATTACK
}
var state := state_type.MOVING

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

@onready var audio_player = $AudioStreamPlayer2D

var player = null

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@rpc("call_local")
func set_state_timer():
	var time = randf_range(0, 10.0)
	%ChangeStateTimer.start(time)
	
@rpc("call_local")
func set_state(new_state):
	state = new_state
	
@rpc("call_local")
func set_chasing(chase_bool):
	chasing_player = chase_bool
	
func _ready():
	if multiplayer.is_server():
		rpc("set_state_timer")
		
func _on_timer_timeout():
	if not chasing_player && multiplayer.is_server():
		var change_state = randi_range(0, 1)
		rpc("set_state", change_state)

	if multiplayer.is_server():
		rpc("set_state_timer")

func _on_chase_player_body_entered(body):
	if (body.get_parent().get_name() == "players") && multiplayer.is_server():
		if (body == player || player == null):
			if not bombshell_detonated:
				player = body
				rpc("set_chasing", true)
				rpc("set_state", state_type.CHASE)

func _on_chase_player_body_exited(body):
	if (body == player):
		player = null
		if not bombshell_detonated:
			rpc("set_chasing", false)
			rpc("set_state", state_type.MOVING)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	#flip sprite
	if (direction > 0):
		animated_sprite.flip_h = true
	elif (direction < 0):
		animated_sprite.flip_h = false
		
	match state:
		state_type.IDLE:
			if bombshell_detonated:
				animated_sprite.play("cooldown_idle")
			else:
				animated_sprite.play("idle")
				
			velocity.x = 0
		state_type.MOVING:
			if bombshell_detonated:
				animated_sprite.play("cooldown_run")
			else:
				animated_sprite.play("run")
				
			if ray_cast_right.is_colliding():
				direction = -1
			elif ray_cast_left.is_colliding():
				direction = 1
				
			velocity.x = direction * SPEED
		state_type.CHASE:
			animated_sprite.play("run")
			
			if multiplayer.is_server():
				if player.global_position.distance_to(global_position) > 8:
					if abs(player.global_position.x - global_position.x) > 8:
						if (player.global_position.x > global_position.x):
							direction = 1
						else:
							direction = -1
						
					velocity.x = direction * SPEED
				else:
					rpc("set_state", state_type.ATTACK)
					
				if ray_cast_right.is_colliding() || ray_cast_left.is_colliding():
					velocity.y = JUMP_VELOCITY
		state_type.ATTACK:
			velocity.x = 0
			
			animated_sprite.play("idle")
			animation_player.play("blink")
			
			if not attack_timer_started:
				%AttackTimer.start(2)
				attack_timer_started = true
				
	move_and_slide()

func _on_cooldown_timer_timeout():
	bombshell_detonated = false

func _on_attack_timer_timeout():
	attack_timer_started = false
	if chasing_player:
		bombshell_detonated = true
		
		#shoot spikes here
		var spike_angle = Vector2(1.0,0.0)
		for i in 7:
			var spike = load("res://scenes/bombshell_spike.tscn").instantiate()
			spike.direction = spike_angle
			spike_angle = spike_angle.rotated(deg_to_rad(-30))
			owner.add_child(spike)
			spike.transform = %"Spike Marker".global_transform
			
		audio_player.play()
		%CooldownTimer.start(10)
		
		state = state_type.MOVING

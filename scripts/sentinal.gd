extends CharacterBody2D

const SPEED = 15.0
const RANGE = 96

var roam_direction = Vector2.UP
var chasing_player = false
var player = null
var player_direction: Vector2
var rand_state_timer = RandomNumberGenerator.new()
var init_position: Vector2
var gravity = -250
var enemy_health = 40
var marked_for_death = false

enum state_type {
	MOVING,
	CHASE,
}
var state := state_type.MOVING

@onready var body_sprite = $BodySprite
@onready var gun_sprite = $GunSprite
@onready var ray_cast_down = $RayCastDown
@onready var ray_cast_up = $RayCastUp
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var audio_stream = $AudioStreamPlayer2D
@onready var animation_player = $AnimationPlayer

func apply_knockback(other_pos):
	var knock_back = 50
	if (other_pos < global_position.x):
		velocity += Vector2(knock_back * 2.5, -knock_back)
	else:
		velocity += Vector2(-knock_back * 2.5, -knock_back)
	
	move_and_slide()
	
@rpc("any_peer", "call_local")
func hurt_enemy(damage: int, other_pos: float):
	animation_player.play("enemy_blink")
	apply_knockback(other_pos)
	enemy_health -= damage
	enemy_health = max(enemy_health, 0)
	
@rpc("call_local", "any_peer")
func destroy_self():
	var soul = load("res://scenes/soul.tscn").instantiate()
	soul.transform = transform
	owner.add_child(soul)
	
	marked_for_death = true
	queue_free()

@rpc("call_local")
func update_direction():
	var rand_direction = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.LEFT, Vector2.RIGHT, Vector2.RIGHT]
	rand_direction.shuffle()
	roam_direction = rand_direction.front()
	var time = randf_range(0, 5.0)
	%RoamTimer.start(time)
	
@rpc("call_local")
func player_entered(_body):
	audio_stream.play()
	player = _body
	chasing_player = true
	state = state_type.CHASE
	%AttackTimer.start()
	
@rpc("call_local")
func player_exited():
	player = null
	chasing_player = false
	state = state_type.MOVING
	%AttackTimer.stop()
	
@rpc("call_local")
func attack(direction):
	var rocket = load("res://scenes/sentinal_rocket.tscn").instantiate()
	owner.add_child(rocket)
	rocket.direction = direction
	rocket.transform = %"Rocket Marker".global_transform
			
func _ready():
	if multiplayer.is_server():
		init_position = global_position
		%RoamTimer.start()

func _physics_process(delta):
	#deal with enemy death
	if multiplayer.is_server():
		if (enemy_health <= 0):
			if (!marked_for_death):
				rpc("destroy_self")
			
	#flip sprite
	if (roam_direction == Vector2.RIGHT):
		body_sprite.flip_h = true
		gun_sprite.rotation = deg_to_rad(-135)
		gun_sprite.flip_v = true
	elif (roam_direction == Vector2.LEFT):
		body_sprite.flip_h = false
		gun_sprite.rotation = deg_to_rad(-45)
		gun_sprite.flip_v = false
		
	match state:
		state_type.MOVING:	
			if ray_cast_right.is_colliding():
				roam_direction = Vector2.LEFT
			elif ray_cast_left.is_colliding():
				roam_direction = Vector2.RIGHT
			elif ray_cast_up.is_colliding():
				roam_direction = Vector2.DOWN
			elif ray_cast_down.is_colliding():
				roam_direction = Vector2.UP
				
			if (global_position.y < init_position.y - RANGE):
				roam_direction = Vector2.DOWN
			elif (global_position.y > init_position.y):
				roam_direction = Vector2.UP
				
			velocity = roam_direction * SPEED
		state_type.CHASE:
			if multiplayer.is_server():
				player_direction = (player.global_position - global_position).normalized()
				if player.global_position.distance_to(global_position) > 32:
					velocity = player_direction * SPEED
				else:
					velocity = Vector2.ZERO
					
				if (player.global_position.x > global_position.x):
					roam_direction = Vector2.RIGHT
				else:
					roam_direction = Vector2.LEFT
				
	if not is_on_floor():
		if not chasing_player && multiplayer.is_server():
			velocity.y += gravity * delta
			
	move_and_slide()
	
func _on_chase_player_body_entered(body):
	if (body.get_parent().get_name() == "players") && multiplayer.is_server():
		if (player == null): #only one player can be targeted
			if (!marked_for_death):
				rpc("player_entered", body)

func _on_chase_player_body_exited(body):
		if (body == player):
			if (!marked_for_death):
				rpc("player_exited")
			
func _on_roam_timer_timeout():
	if not chasing_player:
		if (!marked_for_death):
			rpc("update_direction")

func _on_attack_timer_timeout():
	if multiplayer.is_server():
		if (!marked_for_death):
			rpc("attack", player_direction)

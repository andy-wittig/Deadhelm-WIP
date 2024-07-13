extends CharacterBody2D
#Constants
const SPEED := 15.0
const KNOCK_BACK_SPEED := 75.0
const ROAM_RANGE := 48
const ROAM_CHANGE_WAIT := 5
#Chase Player Variables
var chasing_player = false
var player = null
var player_direction: Vector2
#Roaming Variables
var rand_state_timer = RandomNumberGenerator.new()
var init_position: Vector2
var roam_direction = Vector2.UP
#Physics Variables
var gravity = -250
var knock_back: Vector2
#Enemy Mechanic Variables
var marked_for_death = false
var enemy_health = 40

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

func _ready():
	if multiplayer.is_server():
		init_position = global_position
		%RoamTimer.start()

func apply_knockback(other_pos: Vector2, force: float):
		var other_dir = (other_pos - global_position).normalized()
		knock_back = -other_dir * force
	
@rpc("any_peer", "call_local")
func hurt_enemy(damage: int, other_pos: Vector2, force: float):
	animation_player.play("enemy_blink")
	apply_knockback(other_pos, force)
	
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	get_tree().get_root().add_child(impact)
	impact.position = Vector2(position.x, position.y - 8)
	
	enemy_health -= damage
	enemy_health = max(enemy_health, 0)
	
@rpc("call_local", "any_peer")
func destroy_self():
	var soul = load("res://scenes/level_objects/soul.tscn").instantiate()
	soul.position = position
	get_tree().get_root().add_child(soul)
	
	var explosion = load("res://scenes/vfx/explosion.tscn").instantiate()
	get_tree().get_root().add_child(explosion)
	explosion.position = Vector2(position.x, position.y - 8)
	
	marked_for_death = true
	queue_free()
	
@rpc("call_local")
func attack(direction):
	var rocket = load("res://scenes/enemies/sentinal_rocket.tscn").instantiate()
	rocket.direction = direction
	rocket.transform = %"Rocket Marker".global_transform
	get_tree().get_root().add_child(rocket)
	
func update_rand_direction():
	var rand_x = init_position.x + randi_range(-ROAM_RANGE, ROAM_RANGE)
	var rand_y = init_position.y + randi_range(-ROAM_RANGE, ROAM_RANGE)
	roam_direction = (Vector2(rand_x, rand_y) - global_position).normalized()
	var time = randf_range(0, ROAM_CHANGE_WAIT)
	%RoamTimer.start(time)

func update_direction():
	var rand_direction = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.LEFT, Vector2.RIGHT, Vector2.RIGHT]
	rand_direction.shuffle()
	roam_direction = rand_direction.front()
	var time = randf_range(0, 5.0)
	%RoamTimer.start(time)

func _physics_process(delta):
	#deal with enemy death
	if multiplayer.is_server():
		if (enemy_health <= 0):
			if (!marked_for_death):
				rpc("destroy_self")
			
	#flip sprite
	if (global_position.x + roam_direction.x > global_position.x):
		body_sprite.flip_h = true
		gun_sprite.rotation = deg_to_rad(-135)
		gun_sprite.flip_v = true
	elif (global_position.x + roam_direction.x < global_position.x):
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
				
			if (init_position.distance_to(global_position) >= ROAM_RANGE):
				roam_direction = (init_position - global_position).normalized()
				
			velocity = roam_direction * SPEED
				
		state_type.CHASE:
			if multiplayer.is_server():
				roam_direction = (player.global_position - global_position).normalized()
				if player.global_position.distance_to(global_position) > 64:
					velocity = roam_direction * SPEED
				else:
					velocity = Vector2.ZERO
				
	if not is_on_floor():
		if not chasing_player && multiplayer.is_server():
			velocity.y += gravity * delta
	
	velocity += knock_back
	knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_SPEED)
	knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_SPEED)
	
	move_and_slide()
	
func player_entered(body):
	audio_stream.play()
	player = body
	chasing_player = true
	state = state_type.CHASE
	%AttackTimer.start()
	
func player_exited():
	player = null
	chasing_player = false
	state = state_type.MOVING
	%AttackTimer.stop()
	
func _on_chase_player_body_entered(body):
	if (body.is_in_group("players") && multiplayer.is_server()):
		if (player == null): #only one player can be targeted
			if (!marked_for_death):
				player_entered(body)

func _on_chase_player_body_exited(body):
		if (body == player):
			if (!marked_for_death):
				player_exited()
			
func _on_roam_timer_timeout():
	if not chasing_player:
		if (!marked_for_death):
			update_rand_direction()

func _on_attack_timer_timeout():
	if multiplayer.is_server():
		if (!marked_for_death):
			rpc("attack", roam_direction)

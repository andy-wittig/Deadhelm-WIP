extends CharacterBody2D
#Constants
const SPEED := 30.0
const DASH_SPEED := 220.0
const JUMP_VELOCITY := -180.0
const JUMP_ATTACK_VELOCITY := -280.0
const HANG_TIME_THRESHHOLD := 30.0
const HANG_TIME_MULTIPLIER := 0.2
const KNOCK_BACK_FORCE := 150.0
const ROAM_CHANGE_WAIT := 5
const ATTACK_RADIUS := 48
const ATTACK_WAIT := 3
const ATTACK_TIME := 0.5
#Movement Variables
var rand_state_timer = RandomNumberGenerator.new()
var direction: int
var knock_back: Vector2
#Attacking Variables
var player = null
var chasing_player := false
var jumped := false
#Enemy Mechanics Variables
var enemy_health := 30
var marked_for_death := false

enum state_type {
	MOVING,
	IDLE,
	CHASE,
	ATTACK
}
var state := state_type.MOVING

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var irritus_ghost = preload("res://scenes/vfx/irritus_ghost.tscn")

@onready var chase_player = $ChasePlayer
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedIrritusSprite
@onready var animation_player = $AnimationPlayer
@onready var hurt_player_area = $HurtPlayerArea
	
func _ready():
	hurt_player_area.active = false
	hurt_player_area.attack_wait = ATTACK_WAIT
	
	if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
		direction = [-1, 1].pick_random()
		%RoamTimer.start(randi_range(2, ROAM_CHANGE_WAIT))

func _process(_delta):
	if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
		for body in chase_player.get_overlapping_bodies():
			if (body.is_in_group("players")):
				if (!chasing_player):
					player = body
					chasing_player = true
					state = state_type.CHASE
				return
	#player left detection radius
	player = null
	chasing_player = false

func _physics_process(delta):
	#deal with enemy death
	if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
		if (enemy_health <= 0):
			if (!marked_for_death):
				if (!GameManager.multiplayer_mode_enabled):
					destroy_self()
				elif (multiplayer.is_server()):
					rpc("destroy_self")

	#flip sprite
	if (direction > 0):
		animated_sprite.flip_h = true
	elif (direction < 0):
		animated_sprite.flip_h = false
		
	match state:
		state_type.IDLE:
			if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
				animated_sprite.play("idle")
				velocity.x = 0
		state_type.MOVING:
			if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
				animated_sprite.play("run")
				
				if ray_cast_right.is_colliding():
					direction = -1
				elif ray_cast_left.is_colliding():
					direction = 1
					
				velocity.x = direction * SPEED
		state_type.CHASE:
			if ((multiplayer.is_server() || !GameManager.multiplayer_mode_enabled) && player != null):
				if (player.global_position.x - global_position.x > 8):
						direction = 1
				elif (player.global_position.x - global_position.x < -8):
					direction = -1
				
				if (player.global_position.distance_to(global_position) > ATTACK_RADIUS):
					if (ray_cast_right.is_colliding() || ray_cast_left.is_colliding()
					&& is_on_floor()):
						velocity.y = JUMP_VELOCITY
						
					#handle animations	
					if (is_on_floor()):
						animated_sprite.play("run")
					else:
						animated_sprite.play("jump")
						
					velocity.x = direction * SPEED
				elif (is_on_floor()):
					%CooldownTimer.start(ATTACK_WAIT)
					%GhostTimer.start()
					jumped = false
					state = state_type.ATTACK
		state_type.ATTACK:
				#handle jump dash attack
				if (!jumped):
					velocity = Vector2(0, JUMP_ATTACK_VELOCITY)
					$AttackTimer.start(ATTACK_TIME)
					jumped = true
				elif (is_on_floor()):
					%GhostTimer.stop()
					hurt_player_area.active = false
					animated_sprite.play("idle")
					velocity.x = move_toward(velocity.x, 0, SPEED)
				else:
					animated_sprite.play("jump")

	if not is_on_floor():
		if (abs(velocity.y) < HANG_TIME_THRESHHOLD && state == state_type.ATTACK):
			velocity.y += gravity * HANG_TIME_MULTIPLIER * delta
		else:
			velocity.y += gravity * delta
	
	velocity += knock_back
	knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_FORCE)
	knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_FORCE)
		
	move_and_slide()
	
func _on_attack_timer_timeout():
	if (chasing_player):
		hurt_player_area.active = true
		var dash_vector = (player.global_position - global_position).normalized()
		velocity = dash_vector * DASH_SPEED
		
func _on_ghost_timer_timeout():
	var ghost = irritus_ghost.instantiate()
	ghost.position = position
	get_parent().add_child(ghost)
	
func _on_cooldown_timer_timeout():
	hurt_player_area.active = false
	%GhostTimer.stop()
	
	if (chasing_player):
		state = state_type.CHASE
	else:
		state = state_type.MOVING
	
func _on_change_state_timer_timeout():
	if (not chasing_player):
		if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
			direction = [-1, 1].pick_random()
			state = randi_range(0, 1)
			print(state)
			%RoamTimer.start(randf_range(0, ROAM_CHANGE_WAIT))

func apply_knockback(other_pos: Vector2, force: float):
	var other_dir = (other_pos - global_position).normalized()
	knock_back = -other_dir * force
	
@rpc("any_peer", "call_local")
func hurt_enemy(damage: int, other_pos: Vector2, force: float):
	animation_player.play("hurt_blink")
	apply_knockback(other_pos, force)
	
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	get_parent().add_child(impact)
	impact.position = Vector2(position.x, position.y - 6)
	
	enemy_health -= damage
	enemy_health = max(enemy_health, 0)
	
@rpc("call_local", "any_peer")
func destroy_self():
	var soul = load("res://scenes/level_objects/soul.tscn").instantiate()
	var death_effect = load("res://scenes/vfx/bombshell_turtle_death.tscn").instantiate()
	soul.position = position
	soul.rarities["diamond"] = 80
	soul.rarities["emerald"] = 8
	soul.rarities["gold"] = 4
	soul.rarities["ruby"] = 8
	death_effect.position = position
	get_parent().add_child(soul)
	get_parent().add_child(death_effect)
	
	marked_for_death = true
	queue_free()


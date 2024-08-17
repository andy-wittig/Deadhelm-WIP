extends CharacterBody2D
#Constants
const SPEED = 65.0
const JUMP_VELOCITY = -200.0
const HANG_TIME_THRESHHOLD := 40.0
const HANG_TIME_MULTIPLIER := 0.5
const KNOCK_BACK_SPEED := 75.0
const DETONATE_TIME := 3.0
const ROAM_CHANGE_WAIT := 6
const JUMP_WAIT := 2
const ATTACK_RADIUS := 16
#Movement Variables
var rand_state_timer = RandomNumberGenerator.new()
var direction: int
var jump_timer: float
var knock_back: Vector2
#Attacking Variables
var player = null
var chasing_player = false
var attack_timer_started = false
var attacking = false
var frog_detonated = false
#Enemy Mechanics Variables
var enemy_health = 40
var marked_for_death = false

enum state_type {
	MOVING,
	IDLE,
	CHASE,
	ATTACK
}
var state := state_type.MOVING

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var chase_player = $"chase player"
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
	
func _ready():
	if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
		direction = [-1, 1].pick_random()
		%RoamTimer.start(randi_range(2, ROAM_CHANGE_WAIT))

func _process(_delta):
	if (not frog_detonated):
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
				if (jump_timer <= 0):
					if (is_on_floor()):
						velocity.y = JUMP_VELOCITY
					jump_timer = JUMP_WAIT
				else:
					jump_timer -= delta
				
				if ray_cast_right.is_colliding():
					direction = -1
				elif ray_cast_left.is_colliding():
					direction = 1
					
				if (!is_on_floor()):
					animated_sprite.play("leap")
					velocity.x = direction * SPEED
				else:
					animated_sprite.play("idle")
					velocity.x = move_toward(velocity.x, 0, SPEED)
		state_type.CHASE:
			if ((multiplayer.is_server() || !GameManager.multiplayer_mode_enabled) && player != null):
				if (player.global_position.x - global_position.x > 8):
					direction = 1
				elif (player.global_position.x - global_position.x < -8):
					direction = -1
						
				if (player.global_position.distance_to(global_position) > ATTACK_RADIUS):	
					if (jump_timer <= 0):
						if (is_on_floor()):
							velocity.y = JUMP_VELOCITY
						jump_timer = JUMP_WAIT
					else:
						jump_timer -= delta
					
					if (ray_cast_right.is_colliding() || ray_cast_left.is_colliding()
					&& is_on_floor()):
						velocity.y = JUMP_VELOCITY
						
					if (!is_on_floor()):
						animated_sprite.play("leap")
						velocity.x = direction * SPEED
					else:
						animated_sprite.play("idle")
						velocity.x = move_toward(velocity.x, 0, SPEED)
				else:
					state = state_type.ATTACK
		state_type.ATTACK:
			velocity.x = 0
			animated_sprite.play("primed")
			
			if (animation_player.current_animation != "hurt_blink"):
				animation_player.play("blink")
			
			if not attack_timer_started:
				%AttackTimer.start(DETONATE_TIME)
				attack_timer_started = true
		
	if (!is_on_floor()):
		if (abs(velocity.y) < HANG_TIME_THRESHHOLD):
			velocity.y += gravity * HANG_TIME_MULTIPLIER * delta
		else:
			velocity.y += gravity * delta
	
	velocity += knock_back
	knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_SPEED)
	knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_SPEED)
		
	move_and_slide()
	
func _on_change_state_timer_timeout():
	if (not chasing_player):
		if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
			direction = [-1, 1].pick_random()
			state = randi_range(0, 1)
			%RoamTimer.start(randf_range(0, ROAM_CHANGE_WAIT))

func _on_cooldown_timer_timeout():
	player = null
	chasing_player = false
	frog_detonated = false

func _on_attack_timer_timeout():
	attack_timer_started = false
	if (chasing_player):
		if (!GameManager.multiplayer_mode_enabled):
			detonate()
		elif (multiplayer.is_server()):
			rpc("detonate")
			
		frog_detonated = true
		%CooldownTimer.start(4)
		state = state_type.MOVING

@rpc("call_local")
func detonate():
		var explosion = load("res://scenes/enemies/large_explosion.tscn").instantiate()
		explosion.position = position
		get_parent().add_child(explosion)

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
	soul.rarities["diamond"] = 70
	soul.rarities["emerald"] = 18
	soul.rarities["gold"] = 2
	soul.rarities["ruby"] = 10
	death_effect.position = position
	get_parent().add_child(soul)
	get_parent().add_child(death_effect)
	
	marked_for_death = true
	queue_free()

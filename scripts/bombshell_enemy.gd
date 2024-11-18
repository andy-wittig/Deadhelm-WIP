extends CharacterBody2D
#Constants
const SPEED := 28.0
const JUMP_VELOCITY = -180.0
const KNOCK_BACK_FALLOFF := 20.0
const DETONATE_TIME := 1.0
const ROAM_CHANGE_WAIT := 6
const MAX_HEALTH := 30
#Movement Variables
var rand_state_timer := RandomNumberGenerator.new()
var direction: int
var knock_back: Vector2
#Attacking Variables
var player = null
var chasing_player := false
var attack_timer_started := false
var attacking := false
var bombshell_detonated := false
#Enemy Mechanics Variables
var enemy_health := MAX_HEALTH
var marked_for_death := false

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
@onready var audio_player = $AudioStreamPlayer2D

signal enemy_was_hurt
	
func _ready():
	if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
		direction = [-1, 1].pick_random()
		%RoamTimer.start(randi_range(2, ROAM_CHANGE_WAIT))

func _process(_delta):
	if (!bombshell_detonated):
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
				if bombshell_detonated:
					animated_sprite.play("cooldown_idle")
				else:
					animated_sprite.play("idle")
				
			velocity.x = 0
		state_type.MOVING:
			if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
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
			
			if ((multiplayer.is_server() || !GameManager.multiplayer_mode_enabled) && player != null):
				#follow player
				if abs(player.global_position.x - global_position.x) > 8:
					if (player.global_position.x > global_position.x):
						direction = 1
					else:
						direction = -1
				
				if ((ray_cast_right.is_colliding() || ray_cast_left.is_colliding())
					&& is_on_floor()):
						velocity.y = JUMP_VELOCITY
					
				velocity.x = direction * SPEED
				
				var angle_to_player = rad_to_deg((player.global_position - global_position).normalized().angle())
				if (player.global_position.y < global_position.y + 16): #player is above enemy
					if (angle_to_player >= -105 && angle_to_player <= -75):
						state = state_type.ATTACK
				
				if (player.global_position.distance_to(global_position) <= 24):
					state = state_type.ATTACK
		state_type.ATTACK:
			velocity.x = 0
			
			animated_sprite.play("idle")
			if (animation_player.current_animation != "hurt_blink"):
				animation_player.play("blink")
			
			if not attack_timer_started:
				%AttackTimer.start(DETONATE_TIME)
				attack_timer_started = true
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if (abs(knock_back) > Vector2.ZERO):
		velocity = knock_back
		knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_FALLOFF)
		knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_FALLOFF)
		
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
	bombshell_detonated = false

func _on_attack_timer_timeout():
	attack_timer_started = false
	animation_player.play("RESET")
	if (chasing_player):
		if (multiplayer.is_server()):
			rpc("create_spikes")
		elif (!GameManager.multiplayer_mode_enabled):
			create_spikes()
		audio_player.play()
		bombshell_detonated = true
		%CooldownTimer.start(4)
		state = state_type.MOVING

@rpc("call_local")
func create_spikes():
		var spike_angle = Vector2(1.0,0.0)
		for i in 7:
			var spike = load("res://scenes/enemies/bombshell_spike.tscn").instantiate()
			spike.direction = spike_angle
			spike.position = position + Vector2(0, -4) + spike_angle * 8
			get_parent().add_child(spike)
			
			spike_angle = spike_angle.rotated(deg_to_rad(-30))

func apply_knockback(force_direction: Vector2, force: float):
	knock_back = force_direction.normalized() * force
	
@rpc("any_peer", "call_local")
func hurt_enemy(damage: int, direction: Vector2, force: float):
	emit_signal("enemy_was_hurt")
	animation_player.play("hurt_blink")
	apply_knockback(direction, force)
	
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
	get_tree().call_group("unlock_enemy", "unlock_page", 2)
	queue_free()

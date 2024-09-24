extends CharacterBody2D
#Constants
const SPEED := 16.0
const JUMP_VELOCITY := -175.0
const KNOCK_BACK_FORCE := 100.0
const ROAM_CHANGE_WAIT := 4
const ATTACK_RADIUS := 32
const ATTACK_WAIT := 3
const MAX_HEALTH := 100
#Movement Variables
var rand_state_timer = RandomNumberGenerator.new()
var direction: int
var knock_back: Vector2
#Attacking Variables
var player = null
var chasing_player := false
var attack_started := false
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

@onready var chase_player_area = $ChasePlayerArea
@onready var ray_cast_right = $RightRayCast
@onready var ray_cast_left = $LeftRayCast
@onready var golem_sprite = $GolemSprite
@onready var animation_player = $AnimationPlayer
@onready var hurt_player_area = $HurtPlayerArea

signal enemy_was_hurt
	
func _ready():
	hurt_player_area.active = false
	
	if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
		direction = [-1, 1].pick_random()
		%RoamTimer.start(randi_range(2, ROAM_CHANGE_WAIT))

func _process(_delta):
	if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
		for body in chase_player_area.get_overlapping_bodies():
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
		golem_sprite.flip_h = true
	elif (direction < 0):
		golem_sprite.flip_h = false
		
	match state:
		state_type.IDLE:
			if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
				golem_sprite.play("idle")
				velocity.x = 0
		state_type.MOVING:
			if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
				golem_sprite.play("run")
				
				if ray_cast_right.is_colliding():
					direction = -1
				elif ray_cast_left.is_colliding():
					direction = 1
					
				velocity.x = direction * SPEED
		state_type.CHASE:
			if ((multiplayer.is_server() || !GameManager.multiplayer_mode_enabled) && player != null):
				#follow player
				if abs(player.global_position.x - global_position.x) > 8:
					if (player.global_position.x > global_position.x):
						direction = 1
					else:
						direction = -1
						
				if ((ray_cast_right.is_colliding() || ray_cast_left.is_colliding()) && is_on_floor()):
						velocity.y = JUMP_VELOCITY
						
				velocity.x = direction * SPEED
						
				if (player.global_position.distance_to(global_position) <= ATTACK_RADIUS):
					%CooldownTimer.start(ATTACK_WAIT)
					golem_sprite.stop()
					state = state_type.ATTACK
				else:
					golem_sprite.play("run")
						
		state_type.ATTACK:
			if (!attack_started):
				golem_sprite.play("attack")
				attack_started = true
				
			if (golem_sprite.frame == 5):
				hurt_player_area.active = true
				
			velocity.x = 0

	if not is_on_floor():
		velocity.y += gravity * delta
	
	velocity += knock_back
	knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_FORCE)
	knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_FORCE)
		
	move_and_slide()
	
func _on_golem_sprite_animation_finished():
	if (attack_started):
		golem_sprite.play("idle")
		hurt_player_area.active = false
	
func _on_cooldown_timer_timeout():
	attack_started = false
	if (chasing_player):
		state = state_type.CHASE
	else:
		player = null
		chasing_player = false
		state = state_type.MOVING
	
func _on_change_state_timer_timeout():
	if (not chasing_player):
		if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
			direction = [-1, 1].pick_random()
			state = randi_range(0, 1)
			%RoamTimer.start(randf_range(0, ROAM_CHANGE_WAIT))

func apply_knockback(other_pos: Vector2, force: float):
	var other_dir = (other_pos - global_position).normalized()
	knock_back = -other_dir * force
	
@rpc("any_peer", "call_local")
func hurt_enemy(damage: int, other_pos: Vector2, force: float):
	emit_signal("enemy_was_hurt")
	apply_knockback(other_pos, force)
	animation_player.play("hurt_blink")
	
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	get_parent().add_child(impact)
	impact.position = Vector2(position.x, position.y - 16)
	
	enemy_health -= damage
	enemy_health = max(enemy_health, 0)
	
@rpc("call_local", "any_peer")
func destroy_self():
	var soul = load("res://scenes/level_objects/soul.tscn").instantiate()
	soul.position = position
	soul.rarities["diamond"] = 60
	soul.rarities["emerald"] = 25
	soul.rarities["gold"] = 5
	soul.rarities["ruby"] = 10
	get_parent().add_child(soul)
	
	marked_for_death = true
	queue_free()

extends CharacterBody2D
#Constants
const SPEED := 70.0
const JUMP_VELOCITY := -280.0
const HANG_TIME_THRESHHOLD := 40.0
const HANG_TIME_MULTIPLIER := 0.6
const KNOCK_BACK_FALLOFF := 25.0
const DETONATE_TIME := 0.6
const ROAM_CHANGE_WAIT := 6
const JUMP_WAIT := 1.0
const ATTACK_RADIUS := 24
const MAX_HEALTH := 40
#Movement Variables
var rand_state_timer = RandomNumberGenerator.new()
var direction: int
var jump_timer: float
var knock_back: Vector2
#Attacking Variables
var player = null
var chasing_player := false
var attack_timer_started := false
var attacking := false
var frog_detonated := false
#Enemy Mechanics Variables
var enemy_health := MAX_HEALTH
var marked_for_death := false

enum state_type {
	MOVING,
	IDLE,
	CHASE,
	ATTACK
}
var state := state_type.IDLE

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var chase_player = $"chase player"
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

signal enemy_was_hurt
	
func _ready():
	direction = [-1, 1].pick_random()
	%RoamTimer.start(randi_range(2, ROAM_CHANGE_WAIT))

func _process(_delta):
	if (not frog_detonated):
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
	if (enemy_health <= 0):
		if (!marked_for_death):
			destroy_self()

	#flip sprite
	if (direction > 0):
		animated_sprite.flip_h = true
	elif (direction < 0):
		animated_sprite.flip_h = false
		
	match state:
		state_type.IDLE:
			animated_sprite.play("idle")
			velocity.x = 0
		state_type.MOVING:
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
			else:
				animated_sprite.play("idle")
		state_type.CHASE:
			if (player != null):
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
						
					if (!is_on_floor()):
						animated_sprite.play("leap")
					else:
						animated_sprite.play("idle")
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
			
	if (!is_on_floor()):
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if (abs(knock_back) > Vector2.ZERO):
		velocity = knock_back
		knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_FALLOFF)
		knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_FALLOFF)
		
	move_and_slide()
	
func _on_change_state_timer_timeout():
	if (not chasing_player):
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
		detonate()
		frog_detonated = true
		%CooldownTimer.start(4)
		state = state_type.MOVING

func detonate():
		var explosion = load("res://scenes/enemies/large_explosion.tscn").instantiate()
		explosion.position = position
		get_parent().add_child(explosion)
		
		player.set_screen_shake(0.8)

func apply_knockback(force_direction: Vector2, force: float):
	knock_back = force_direction.normalized() * force

func hurt_enemy(damage: int, direction: Vector2, force: float):
	emit_signal("enemy_was_hurt")
	animation_player.play("hurt_blink")
	apply_knockback(direction, force)
	
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	impact.position = Vector2(position.x, position.y - 6)
	get_parent().add_child(impact)
	impact.reset_physics_interpolation()
	
	enemy_health -= damage
	enemy_health = max(enemy_health, 0)

func destroy_self():
	get_tree().call_group("unlock_enemy", "unlock_page", 3)
	
	var soul = load("res://scenes/level_objects/soul.tscn").instantiate()
	soul.position = position
	soul.rarities["diamond"] = 60
	soul.rarities["emerald"] = 20
	soul.rarities["gold"] = 5
	soul.rarities["ruby"] = 15
	get_parent().add_child(soul)
	var death_effect = load("res://scenes/vfx/chunk_effect.tscn").instantiate()
	death_effect.global_position = Vector2(global_position.x, global_position.y - 8)
	get_parent().add_child(death_effect)
	
	marked_for_death = true
	queue_free()

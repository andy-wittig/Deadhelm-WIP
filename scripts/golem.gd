extends CharacterBody2D
#Constants
const SPEED := 30.0
const JUMP_VELOCITY := -180.0
const KNOCK_BACK_FALLOFF := 75.0
const ROAM_CHANGE_WAIT := 4
const ATTACK_RADIUS := 24
const ATTACK_WAIT := 2
const MAX_HEALTH := 100
#Movement Variables
var rand_state_timer := RandomNumberGenerator.new()
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
@onready var attack_indicator = $AttackIndicator

signal enemy_was_hurt
	
func _ready():
	hurt_player_area.active = false
	attack_indicator.visible = false
	direction = [-1, 1].pick_random()
	%RoamTimer.start(randi_range(2, ROAM_CHANGE_WAIT))

func _process(_delta):
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
	if (enemy_health <= 0):
		if (!marked_for_death):
			destroy_self()

	#flip sprite
	if (direction > 0):
		golem_sprite.flip_h = true
	elif (direction < 0):
		golem_sprite.flip_h = false
		
	match state:
		state_type.IDLE:
			golem_sprite.play("idle")
			velocity.x = 0
		state_type.MOVING:
			golem_sprite.play("run")
			
			if ray_cast_right.is_colliding():
				direction = -1
			elif ray_cast_left.is_colliding():
				direction = 1
				
			velocity.x = direction * SPEED
		state_type.CHASE:
			if (player != null):
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
						
				if ((player.global_position.distance_to(global_position) <= ATTACK_RADIUS)
				&& (player.global_position.y + 2 >= global_position.y)
				&& is_on_floor()):
					%CooldownTimer.start(ATTACK_WAIT)
					golem_sprite.stop()
					state = state_type.ATTACK
				else:
					golem_sprite.play("run")
						
		state_type.ATTACK:
			if (!attack_started):
				golem_sprite.play("attack")
				animation_player.play("attack_indicator")
				attack_indicator.visible = true
				attack_started = true
				
			if (golem_sprite.frame == 5 && player != null):
				player.set_screen_shake(1.0)
				$DustParticles.emitting = true
				$ChunkParticles.emitting = true
				attack_indicator.visible = false
				hurt_player_area.active = true
				
			if (golem_sprite.frame == 7):
				hurt_player_area.active = false
				
			velocity.x = 0

	if not is_on_floor():
		velocity.y += gravity * delta
	
	if (abs(knock_back) > Vector2.ZERO):
		velocity = knock_back
		knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_FALLOFF)
		knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_FALLOFF)
		
	move_and_slide()
	
func _on_golem_sprite_animation_finished():
	if (attack_started):
		golem_sprite.play("idle")
	
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
		direction = [-1, 1].pick_random()
		state = randi_range(0, 1)
		%RoamTimer.start(randf_range(0, ROAM_CHANGE_WAIT))

func apply_knockback(force_direction: Vector2, force: float):
	knock_back = force_direction.normalized() * force

func hurt_enemy(damage: int, direction: Vector2, force: float):
	emit_signal("enemy_was_hurt")
	apply_knockback(direction, force)
	animation_player.play("hurt_blink")
	
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	impact.position = Vector2(position.x, position.y - 16)
	get_parent().add_child(impact)
	impact.reset_physics_interpolation()
	
	enemy_health -= damage
	enemy_health = max(enemy_health, 0)

func destroy_self():
	get_tree().call_group("unlock_enemy", "unlock_page", 7)
	
	var soul = load("res://scenes/level_objects/soul.tscn").instantiate()
	soul.position = position
	soul.rarities["diamond"] = 55
	soul.rarities["emerald"] = 15
	soul.rarities["gold"] = 20
	soul.rarities["ruby"] = 10
	get_parent().add_child(soul)
	
	marked_for_death = true
	queue_free()

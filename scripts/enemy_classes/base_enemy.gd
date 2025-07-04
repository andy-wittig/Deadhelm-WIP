extends CharacterBody2D

class_name BaseEnemy

#enemy components
@export var enemy_sprite : AnimatedSprite2D
@export var animation_player : AnimationPlayer
@export var left_raycast : RayCast2D
@export var right_raycast : RayCast2D
@export var chase_area : Area2D

#enemy movement
@export var SPEED := 35.0
@export var FRICTION_SPEED := 6.0
@export var JUMP_VELOCITY := -180.0
@export var KNOCK_BACK_FALLOFF := 25.0
@export var ATTACK_RANGE := 16.0
@export var DODGE_RANGE := 8.0
@export var DODGE_SPEED := 45.0
@export var enemy_health : int
@export var MAX_HEALTH : int

#enemy mechanics
@export var roam_timer_wait : float
@export var attack_timer_wait : float
@export var cooldown_timer_wait : float
@export var enemy_center_offset : Vector2
@export var drop_rarity : Array[int] = [25, 25, 25, 25]
@export var enemy_page : int

var direction : int
var knock_back : Vector2
var extra_h_velocity : float

#enemy chasing
var player = null
var chasing_player := false
var attack_started := false
var attacking := false

enum state_type {
	MOVING,
	IDLE,
	CHASE,
	ATTACK
}
var state := state_type.IDLE

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var roam_timer = Timer.new()
var cooldown_timer = Timer.new()
var attack_timer = Timer.new()

signal enemy_was_hurt

func _ready():
	add_child(roam_timer)
	add_child(cooldown_timer)
	add_child(attack_timer)
	
	attack_timer.one_shot = true
	cooldown_timer.one_shot = true
	roam_timer.one_shot = false
	
	attack_timer.timeout.connect(attack_finished)
	cooldown_timer.timeout.connect(cooldown_finished)
	roam_timer.timeout.connect(change_state)
	
	roam_timer.start(randi_range(1, roam_timer_wait))
	direction = [-1, 1].pick_random()
	
func detect_player():
	for body in chase_area.get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!chasing_player):
				player = body
				chasing_player = true
				state = state_type.CHASE
			return
			
	#player leaves the detection radius
	player = null
	chasing_player = false
	
func handle_enemy_death():
	if (enemy_health <= 0):
		get_tree().call_group("unlock_enemy", "unlock_page", "Enemy", enemy_page)
	
		var soul = load("res://scenes/level_objects/soul.tscn").instantiate()
		soul.position = position + enemy_center_offset
		soul.rarities["diamond"] = drop_rarity[0]
		soul.rarities["emerald"] = drop_rarity[1]
		soul.rarities["gold"] = drop_rarity[2]
		soul.rarities["ruby"] = drop_rarity[3]
		
		var death_effect = load("res://scenes/vfx/chunk_effect.tscn").instantiate()
		death_effect.position = position + enemy_center_offset
		
		get_parent().add_child(death_effect)
		get_parent().add_child(soul)
		
		call_deferred("queue_free")

func _process(_delta):
	detect_player()
	handle_enemy_death()

func move_enemy(delta):
	enemy_sprite.play("run")
			
	if right_raycast.is_colliding():
		direction = -1
	elif left_raycast.is_colliding():
		direction = 1
	
	velocity.x = direction * SPEED
	
func chase_player(delta):
	if (player != null):
		#chase towards player's direction
		var distance_to_player = player.global_position.distance_to(global_position)
		direction = sign(player.global_position.x - global_position.x)
		
		if (distance_to_player > ATTACK_RANGE):
			enemy_sprite.play("run")
			
			if ((right_raycast.is_colliding() || left_raycast.is_colliding())
			&& is_on_floor()):
				velocity.y = JUMP_VELOCITY
				
			velocity.x = direction * SPEED
		else: #player is within attacking range
			enemy_sprite.stop()
			state = state_type.ATTACK

func _physics_process(delta):
	extra_h_velocity = 0
	
	if (direction > 0):
		enemy_sprite.flip_h = true
	elif (direction < 0):	
		enemy_sprite.flip_h = false
	
	match state:
		state_type.IDLE:
			enemy_sprite.play("idle")
			velocity.x = 0
		state_type.MOVING:
			move_enemy(delta)
		state_type.CHASE:
			chase_player(delta)
		state_type.ATTACK:
			start_enemy_attack()

	calculate_velocity(delta)
	
	move_and_slide()
	
func calculate_velocity(delta):
	if (abs(knock_back) > Vector2.ZERO):
		velocity = knock_back
		knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_FALLOFF)
		knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_FALLOFF)
		
	velocity.x += extra_h_velocity
		
	if (!is_on_floor()):
		enemy_sprite.play("fall")
		velocity.y += gravity * delta
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION_SPEED)
	
func start_enemy_attack():
	if (!attack_started):
		velocity.x = 0
		attack_started = true
		enemy_sprite.play("attack")
		attack_timer.start(attack_timer_wait)

func attack_finished():
	enemy_sprite.play("idle")
	cooldown_timer.start(cooldown_timer_wait)
	
func cooldown_finished():
	attack_started = false
	
	if (chasing_player):
		state = state_type.CHASE
	else:
		player = null
		state = state_type.MOVING
	
func change_state():
	if (!chasing_player):
		direction = [-1, 1].pick_random()
		state = randi_range(0, 1)
		roam_timer.start(randf_range(1, roam_timer_wait))

func apply_knockback(force_direction: Vector2, force: float):
	knock_back = force_direction.normalized() * force

func hurt_enemy(damage: int, direction: Vector2, force: float):
	emit_signal("enemy_was_hurt")
	animation_player.play("hurt_blink")
	apply_knockback(direction, force)
	
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	impact.position = position + enemy_center_offset
	get_parent().add_child(impact)
	impact.reset_physics_interpolation()
	
	enemy_health -= damage
	enemy_health = max(enemy_health, 0)
